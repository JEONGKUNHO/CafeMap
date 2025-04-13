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
    @Binding var currentLocation: CLLocationCoordinate2D?
    @Binding var isMapDragged: Bool
    @Binding var reloadButtonClicked: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        mapView.pointOfInterestFilter = MKPointOfInterestFilter(including: [.publicTransport])
        mapView.showsUserLocation = true
        mapView.setRegion(region, animated: true)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        guard reloadButtonClicked || mapView.annotations.isEmpty else { return }
        
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
            
            let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
            let iconImage = UIImage(systemName: "mappin.circle.fill", withConfiguration: config)?
                .withTintColor(.red, renderingMode: .alwaysOriginal)
            let imageView = UIImageView(image: iconImage)
            imageView.contentMode = .scaleAspectFit
            
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 10)
            label.textAlignment = .center
            label.textColor = .black
            label.numberOfLines = 1
            
            if let customAnnotation = annotation as? CustomAnnotation {
                label.text = customAnnotation.title
            }
            
            let stackView = UIStackView(arrangedSubviews: [imageView, label])
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 2
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = false
                annotationView?.isEnabled = true
            } else {
                annotationView?.subviews.forEach { $0.removeFromSuperview() }
                annotationView?.annotation = annotation
            }
            
            annotationView?.addSubview(stackView)
            
            NSLayoutConstraint.activate([
                stackView.centerXAnchor.constraint(equalTo: annotationView!.centerXAnchor),
                stackView.centerYAnchor.constraint(equalTo: annotationView!.centerYAnchor)
            ])
            
            return annotationView
        }
        
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            if parent.region.center.latitude.rounded(toPlaces: 5) != mapView.centerCoordinate.latitude.rounded(toPlaces: 5)
                && parent.region.center.longitude.rounded(toPlaces: 5) != mapView.centerCoordinate.longitude.rounded(toPlaces: 5) {
                parent.isMapDragged = true
                parent.currentLocation = mapView.centerCoordinate
            }
        }
        
        func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
            parent.reloadButtonClicked = false
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
