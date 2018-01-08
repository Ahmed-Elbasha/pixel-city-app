//
//  MapViewController.swift
//  Pixel-City
//
//  Created by Ahmed Elbasha on 11/23/17.
//  Copyright © 2017 Ahmed Elbasha. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pullUpView: UIView!
    
    // these variables and constants declared to help in determining the user location.
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius: Double = 1000
    
    // this variable represents the size of current device screen.
    var screen = UIScreen.main.bounds
    
    // these variables declared to add spinner and progressLabel to our pullUpView.
    var spinner: UIActivityIndicatorView?
    var progressLabel: UILabel?
    
    // these variables declared to add collectionView to pullUpView.
    var layoutFlow = UICollectionViewFlowLayout()
    var collectionView: UICollectionView?
    
    // these variables declared to add an array for images URLS and an array for UIImage objects.
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // sets MapVC as a delegate for mapView.
        mapView.delegate = self
        // sets MapVC as a delegate for locationManager.
        locationManager.delegate = self
        // this is a method call for configureLocationServices function that is responsible for configuring location services.
        configureLocationServices()
        // to add UITapGestureRecognizer
        addDoubleTap()
        // to add CollectionView to pullUpView.
        addCollectiovView()
        
        registerForPreviewing(with: self, sourceView: collectionView!)
    }
    
    // adds CollectionView to pullUpView.
    func addCollectiovView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layoutFlow)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        pullUpView.addSubview(collectionView!)
    }

    // adds UITapGestureRecognizer Object to the view.
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    // adds UISwipeGestureRecognizer to swipe pullUpView down.
    func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    // animates the pullUpView up with the moment that user drops a pin.
    func animateViewUp() {
        self.pullUpViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.03) {
            self.view.layoutIfNeeded()
        }
    }
    
    // animates the pullUpView down with the moment that user swipes down it.
    @objc func animateViewDown() {
        cancelAllSessions()
        self.pullUpViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.03) {
            self.view.layoutIfNeeded()
        }
    }
    
    // Adds a Spinner to the CollectionView with the moment that user drops a pin on mapView.
    func addSpinner() {
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screen.width / 2)  - ((spinner?.frame.width)! / 2), y: 150)
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    // Adds a Progress label to the CollectionView with the moment that user drops a pin on mapView.
    func addProgressLabel() {
        progressLabel = UILabel()
        progressLabel?.frame = CGRect(x: (screen.width / 2) - 120 , y: 175, width: 240, height: 40)
        progressLabel?.font = UIFont(name: "Avenir Next", size: 14)
        progressLabel?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        progressLabel?.textAlignment = .center
        collectionView?.addSubview(progressLabel!)
    }
    
    // Removes the Spinner from the CollectionView with the moment that user drops a new pin on mapView.
    func removeSpinner() {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    // Removes the Progress label from the CollectionView with the moment that user drops a new pin on mapView.
    func removeProgressLabel() {
        if progressLabel != nil {
            progressLabel?.removeFromSuperview()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // re-center the map based on user location.
    @IBAction func centerMapButtonWasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapsOnUserLocation()
        }
    }
    
    // this function retrieves the images Urls from JSON Data Response using AlamoFire.
    func retrieveUrls(forAnnotation annotation: DroppablePin, handler: @escaping ( _ status: Bool) -> () ) {
        // requests JSON response then retreives the images URLS using AlamoFire.
        Alamofire.request(FlickrUrl(forApiKey: apikey, withAnnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in
            guard let json = response.result.value as? Dictionary<String,AnyObject> else { return }
            let photoDictionary = json["photos"] as! Dictionary<String,AnyObject>
            let photoDictionaryArray = photoDictionary["photo"] as! [Dictionary<String,AnyObject>]
            for photo in photoDictionaryArray {
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                self.imageUrlArray.append(postUrl)
            }
            handler(true)
        }
    }
    
    // retreives the images urls stored in imageUrlArray and downloads it using AlamoFireImage.
    func retrieveImages(handler: @escaping (_ status: Bool) -> ()) {
        for url in imageUrlArray {
            Alamofire.request(url).responseImage(completionHandler: { (response) in
                guard let image = response.result.value else { return }
                self.imageArray.append(image)
                self.progressLabel?.text = "\(self.imageArray.count)/40 PHOTOS DOWNLOADED"
                
                if self.imageArray.count == self.imageUrlArray.count {
                    handler(true)
                }
            })
        }
    }
    
    // cancels all the AlamoFire sessions when the user swipes down the pullUpView or drops a new pin.
    func cancelAllSessions() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadTask, downloadTask) in
            sessionDataTask.forEach({ $0.cancel() })
            downloadTask.forEach({ $0.cancel() })
        }
    }
}

// conforms to MKMapViewDelegate.
extension MapViewController: MKMapViewDelegate {
    
    // customizes the style of the annotation pin.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.tintColor = #colorLiteral(red: 0.9771530032, green: 0.7062081099, blue: 0.1748393774, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    // centers the map on user location coordinate.
    func centerMapsOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    // determines what happens with the moment user drops a new pin.
    @objc func dropPin(sender: UITapGestureRecognizer) {
       // removes all the existing pins.
       removePin()
       // removes all the existing spinners.
       removeSpinner()
       // removes all the existing progress labels.
       removeProgressLabel()
       // cancels all the existing AlamoFire Sessions.
       cancelAllSessions()
       
       // clears the imageUrlArray and imageArray of elements.
       imageUrlArray = []
       imageArray = []
       
       // reloades the CollectionView's data.
       collectionView?.reloadData()
       
       // animates the pullUpView up.
       animateViewUp()
       
       // adds a new UISwipeGestureRecognizer.
       addSwipe()
       // adds a new spinner.
       addSpinner()
       // adds a new progress label.
       addProgressLabel()
       
       // turns the new user touch point into coordinates
       let touchPoint = sender.location(in: mapView)
       let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)

       // creates a new Annotation pin on the touch point coordinate.
       let Annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
       mapView.addAnnotation(Annotation)

       // centers the map on the new dropped pin location.
       let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
        // retrieves the images urls related to the new dropped pin location, downloads images from these urls and reloads it into CollectionView.
        retrieveUrls(forAnnotation: Annotation) { (finished) in
            if finished {
                self.retrieveImages(handler: { (finished) in
                    if finished {
                        //Remove spinner.
                        self.removeSpinner()
                        //Remove progressLabel.
                        self.removeProgressLabel()
                        //Reload CollectionView.
                        self.collectionView?.reloadData()
                    }
                })
            }
        }
    }

    // removes any existing pins with the moment user drops a new pin on mapView.
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
}

// conforms to CLLocationManagerDelegate protocol.
extension MapViewController: CLLocationManagerDelegate {
    
    // asks for GPS Service permission and using it.
    func configureLocationServices() {
        if authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            return
        }
    }

    // centers the map on user location with the moment that GPS Service usage permited
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapsOnUserLocation()
    }
}

// conforms to UIGestureRecognizerDelegate protocol.
extension MapViewController: UIGestureRecognizerDelegate {
    
}

//conforms to UICollectionViewDelegate and UICollectionViewDataSource protocols.
extension MapViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // Determines the number os sections in collectionView.
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // Determines the number of items of each section in CollectionView.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // returns number of items in an array
        return imageArray.count
    }
    
    // Determines what every cell in CollectionView consists of.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else { return UICollectionViewCell() }
        let imageFromIndexPath = imageArray[indexPath.row]
        let imageView = UIImageView(image: imageFromIndexPath)
        cell.addSubview(imageView)
        return cell
    }
    
    // Determines what could be happen if we selected a cell in CollectionView.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopViewController else { return }
        popVC.initData(forImage: imageArray[indexPath.row])
        present(popVC, animated: true, completion: nil)
    }
}

// conforms to UIViewControllerPreviewingDelegate protocol.
extension MapViewController: UIViewControllerPreviewingDelegate {
    // determines the desired behavior when we push hard on an ImageCell.
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView?.indexPathForItem(at: location), let cell = collectionView?.cellForItem(at: indexPath) else {return nil}
        
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopViewController else {return nil}
        
        previewingContext.sourceRect = cell.contentView.frame
        return popVC
    }
    
    // determines the desired behavior when we peek at ImageCell.
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}











