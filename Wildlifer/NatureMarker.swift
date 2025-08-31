//
//  NatureMarker.swift
//  Wildlifer
//
//  Created by Benjamin Olea on 8/30/25.
//

//
//  MapMarkerModel.swift
//  Wildlifer
//
//  Created by Benjamin Olea on 8/29/25.
//

import Foundation
import GoogleMaps
import UIKit

struct NatureMarker: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
    let snippet: String?
    let color: UIColor
    let icon: UIImage?
    
    init(coordinate: CLLocationCoordinate2D, title: String, snippet: String? = nil, color: UIColor = .red, icon: UIImage? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.snippet = snippet
        self.color = color
        self.icon = icon
    }
}
