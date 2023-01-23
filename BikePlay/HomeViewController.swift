//
//  HomeViewController.swift
//  BikePlay
//
//  Created by Matthew Picozzi on 2023-01-09.
//

import UIKit
import MapKit
import CoreLocation
class HomeViewController: UIViewController {

    
    var mapView = MKMapView()
    let locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
        
        setupLayout()
    }
    
    func setupLayout() {
        view.addSubview(mapView)
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        manager.stopUpdatingLocation()
        guard let currentLocation = locations.first else { return }
        currentCoordinate = currentLocation.coordinate
        mapView.setUserTrackingMode(.follow, animated: true)
    }
}

