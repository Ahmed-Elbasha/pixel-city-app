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

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func centerMapButtonWasPressed(_ sender: Any) {
    }
    
}

extension MapViewController: MKMapViewDelegate {

}
