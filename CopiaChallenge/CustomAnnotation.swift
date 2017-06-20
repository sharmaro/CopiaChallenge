//
//  CustomAnnotation.swift
//  CopiaChallenge
//
//  Created by Rohan Sharma on 6/19/17.
//  Copyright © 2017 Zin. All rights reserved.
//

import Foundation
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        
        super.init()
    }    
}
