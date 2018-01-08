//
//  DroppablePin.swift
//  Pixel-City
//
//  Created by Ahmed Elbasha on 12/1/17.
//  Copyright © 2017 Ahmed Elbasha. All rights reserved.
//

import UIKit
import MapKit

class DroppablePin: NSObject, MKAnnotation {

    var coordinate: CLLocationCoordinate2D
    var identifier: String

    // initializes a Droppable Annotation Pin.
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
}
