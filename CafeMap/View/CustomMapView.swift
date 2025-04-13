//
//  CustomMapView.swift
//  CafeMap
//
//  Created by 정건호 on 4/12/25.
//

import SwiftUI
import MapKit

struct CustomMapView: UIViewRepresentable {
    var region: MKCoordinateRegion
    var places: [CafePlace]
    var onAnnotationTap: (CafePlace) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        mapView.pointOfInterestFilter = .excludingAll
        mapView.showsUserLocation = true
        mapView.setRegion(region, animated: false)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.setRegion(region, animated: true)
        
        mapView.removeAnnotations(mapView.annotations)
        
        let annotations = places.map { place in
            let annotation = CustomAnnotation(place: place)
            annotation.coordinate = place.coordinate
            annotation.title = place.displayName
            return annotation
        }
        mapView.addAnnotations(annotations)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView
        
        init(_ parent: CustomMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation as? CustomAnnotation {
                parent.onAnnotationTap(annotation.place)
            }
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            
            let identifier = "CustomAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = false
                annotationView?.isEnabled = true
                
                let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
                let iconImage = UIImage(systemName: "mappin.circle.fill", withConfiguration: config)?
                    .withTintColor(.red, renderingMode: .alwaysOriginal)
                let imageView = UIImageView(image: iconImage)
                imageView.contentMode = .scaleAspectFit
                
                let label = UILabel()
                label.text = annotation.title ?? ""
                label.font = UIFont.systemFont(ofSize: 10)
                label.textAlignment = .center
                label.textColor = .black
                label.numberOfLines = 1
                
                let stackView = UIStackView(arrangedSubviews: [imageView, label])
                stackView.axis = .vertical
                stackView.alignment = .center
                stackView.spacing = 2
                
                stackView.translatesAutoresizingMaskIntoConstraints = false
                annotationView?.addSubview(stackView)
                
                NSLayoutConstraint.activate([
                    stackView.centerXAnchor.constraint(equalTo: annotationView!.centerXAnchor),
                    stackView.centerYAnchor.constraint(equalTo: annotationView!.centerYAnchor)
                ])
            }
            
            return annotationView
        }
        
    }
    
    class CustomAnnotation: NSObject, MKAnnotation {
        let place: CafePlace
        var coordinate: CLLocationCoordinate2D
        var title: String?
        
        init(place: CafePlace) {
            self.place = place
            self.coordinate = place.coordinate
            self.title = place.displayName
        }
    }
}
