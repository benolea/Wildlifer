//
//  GoogleMapViewNature.swift
//  Wildlifer
//
//  Created by Benjamin Olea on 8/30/25.
//

import SwiftUI
import GoogleMaps

struct GoogleMapViewNature: UIViewRepresentable {
    
    @Binding var natureMarkers: [NatureMarker]
    
    let initialCamera: GMSCameraPosition
    let onMarkerTap: ((NatureMarker) -> Bool)?
    //let onMapTap: ((CLLocationCoordinate2D) -> Void)?
    
    init(markers :Binding<[NatureMarker]> = .constant([]),
         initialCamera: GMSCameraPosition,
         onMarkerTap: ((NatureMarker) -> Bool)? = nil)
    {
        self._natureMarkers = markers
        self.initialCamera = initialCamera
        self.onMarkerTap = onMarkerTap
    }
    
    
    func makeUIView(context: Context) -> GMSMapView {
        let mapView = GMSMapView(frame: .zero, camera: initialCamera)
        mapView.delegate = context.coordinator
        
        // Optional: Enable user location
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        // Optional: Configure map UI
        mapView.settings.compassButton = true
        mapView.settings.zoomGestures = true
        mapView.settings.scrollGestures = true
        mapView.settings.rotateGestures = true
        mapView.settings.tiltGestures = true
        
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context){
        mapView.clear()
        
        updateMarkers(mapView, context: context)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func updateMarkers(_ mapView: GMSMapView, context: Context){
        for markerData in natureMarkers {
            let marker = GMSMarker()
            marker.position = markerData.coordinate
            marker.title = markerData.title
            marker.snippet = markerData.snippet
            
            if let customIcon = markerData.icon{
                marker.icon = customIcon
            }else {
                marker.icon = GMSMarker.markerImage(with: markerData.color)
            }
            
            marker.userData = markerData
            marker.map = mapView
        }
    }
}

extension GoogleMapViewNature {
    class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: GoogleMapViewNature
        
        init(_ parent: GoogleMapViewNature){
            self.parent = parent
        }
        
        // Handle marker tap events
        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            if let markerData = marker.userData as? NatureMarker{
                return parent.onMarkerTap?(markerData) ?? false
            }
            return false
        }
    }
}
