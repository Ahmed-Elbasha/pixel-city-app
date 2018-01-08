//
//  Constants.swift
//  Pixel-City
//
//  Created by Ahmed Elbasha on 12/12/17.
//  Copyright © 2017 Ahmed Elbasha. All rights reserved.
//

import Foundation

// this is our Flicker Api's Key.
let apikey = "03fe9324f376deabe27578aa528fd348"

// Generates the Flicker Api Url.
func FlickrUrl(forApiKey key:String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String {
    return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apikey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
}


