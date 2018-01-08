//
//  PopViewController.swift
//  Pixel-City
//
//  Created by Ahmed Elbasha on 12/21/17.
//  Copyright © 2017 Ahmed Elbasha. All rights reserved.
//

import UIKit

class PopViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var popImageView: UIImageView!
    
    var passedImage: UIImage!
    
    func initData(forImage image: UIImage) {
        self.passedImage = image
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // sets the passed image as a value for popImageView.
        self.popImageView.image = self.passedImage
        addDoubleTap()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    // adds UITapGestureRecognizer
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    
    // dismisses the UIViewController when we double tap occured.
    @objc func screenDoubleTapped() {
        dismiss(animated: true, completion: nil)
    }
}
