//
//  ViewController.swift
//  PlacemarkMap
//
//  Created by Daniil Aleshchenko on 27.03.2022.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
	
	// Create map
	let mapView: MKMapView = {
		let mapView = MKMapView()
		mapView.translatesAutoresizingMaskIntoConstraints = false
		return mapView
	}()
	
	// Create buttons on map
	
	let addPlacemarkButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage(named: "addPlacemark"), for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	let routeButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage(named: "route"), for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isHidden = true
		return button
	}()
	
	let trashButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage(named: "trash"), for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isHidden = true
		return button
	}()
	
	// Annotations array
	var annotationsArray = [MKPointAnnotation]()

	override func viewDidLoad() {
		super.viewDidLoad()
		
		mapView.delegate = self
		
		setConstraints()
		
		// Button targets
		addPlacemarkButton.addTarget(self, action: #selector(addPlacemarkButtonTapped), for: .touchUpInside)
		routeButton.addTarget(self, action: #selector(routeButtonTapped), for: .touchUpInside)
		trashButton.addTarget(self, action: #selector(trashButtonTapped), for: .touchUpInside)
	}
	
	@objc func addPlacemarkButtonTapped() {
		
		alertAddPlacemark(title: "Add Placemark", placeholder: "Please enter an address") { [self] (text) in
			setupPlacemark(addressPlace: text)
		}
	}
	
	@objc func routeButtonTapped() {
		
		for index in 0...annotationsArray.count - 2 {
			
			createRoute(startCoordinate: annotationsArray[index].coordinate, destinationCoordinate: annotationsArray[index + 1].coordinate)
		}
		
		mapView.showAnnotations(annotationsArray, animated: true)
	}
	
	@objc func trashButtonTapped() {
		
		mapView.removeOverlays(mapView.overlays)
		mapView.removeAnnotations(mapView.annotations)
		annotationsArray = [MKPointAnnotation]()
		routeButton.isHidden = true
		trashButton.isHidden = true
	}
	
	// Create annotation
	func setupPlacemark(addressPlace: String) {
		
		let geocoder = CLGeocoder()
		geocoder.geocodeAddressString(addressPlace) { [self] (placemarks, error) in
			
			if let error = error {
				print(error)
				alertError(title: "Error", message: "Server is not available or address is incorrect")
				return
			}
			
			guard let placemarks = placemarks else { return }
			let placemark = placemarks.first
			
			let annotation = MKPointAnnotation()
			annotation.title = "\(addressPlace)"
			guard let placemarkLocation = placemark?.location else { return }
			annotation.coordinate = placemarkLocation.coordinate
			
			annotationsArray.append(annotation)
			
			if annotationsArray.count > 1 {
				trashButton.isHidden = false
				routeButton.isHidden = false
			}
			
			
			mapView.showAnnotations(annotationsArray, animated: true)
		}
	}
	
	// Route calculation
	
	func createRoute(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
		
		let startLocation = MKPlacemark(coordinate: startCoordinate)
		let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
		
		let request = MKDirections.Request()
		request.source = MKMapItem(placemark: startLocation)
		request.destination = MKMapItem(placemark: destinationLocation)
		request.transportType = .walking
		request.requestsAlternateRoutes = true
		
		let direction = MKDirections(request: request)
		direction.calculate { (response, error) in
			
			if let error = error {
				print(error)
				return
			}
			
			guard let response = response else {
				self.alertError(title: "Error", message: "Route unavailable")
				return
			}
			
			// Calculate the minimum route
			var minRoute = response.routes[0]
			for route in response.routes {
				minRoute = (route.distance < minRoute.distance) ? route : minRoute
			}
			
			self.mapView.addOverlay(minRoute.polyline)
		}
	}
}



extension ViewController: MKMapViewDelegate {
	
	// Configuration polyline
	
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		
		let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
		render.strokeColor = .red
		return render
	}
	
	// Create Constraints
	func setConstraints() {
		
		// Set constraints for map
		view.addSubview(mapView)
		NSLayoutConstraint.activate([
			
			mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
			mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
			mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
			mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
		])
		
		// Set contraints for buttons
		
		mapView.addSubview(addPlacemarkButton)
		NSLayoutConstraint.activate([
			addPlacemarkButton.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 50),
			addPlacemarkButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
			addPlacemarkButton.heightAnchor.constraint(equalToConstant: 70),
			addPlacemarkButton.widthAnchor.constraint(equalToConstant: 70)
		])
		
		mapView.addSubview(routeButton)
		NSLayoutConstraint.activate([
			routeButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 10),
			routeButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -70),
			routeButton.heightAnchor.constraint(equalToConstant: 50),
			routeButton.widthAnchor.constraint(equalToConstant: 50)
		])
		
		mapView.addSubview(trashButton)
		NSLayoutConstraint.activate([
			trashButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10),
			trashButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -70),
			trashButton.heightAnchor.constraint(equalToConstant: 50),
			trashButton.widthAnchor.constraint(equalToConstant: 50)
		])
		
	}
	
}
