//
//  HomeViewController.swift
//  BikePlay
//
//  Created by Matthew Picozzi on 2023-01-09.
//

import UIKit
import MapKit
import CoreLocation

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

protocol SelectAlternateRoute {
    func showAlternate(selectedRoute:MKRoute, index:Int)
}

protocol StartRoute {
    func startButtonPressed(index:Int)
}

extension MKPolyline {
    struct ColorHolder {
        static var _color: UIColor?
    }
    var color: UIColor? {
        get {
            return ColorHolder._color
        }
        set(newValue) {
            ColorHolder._color = newValue
        }
    }
}

class HomeViewController: UIViewController {
    
    var selectedPin:MKPlacemark? = nil
    var steps = [MKRoute.Step]()
    var routes:[MKRoute] = []

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D!
    var searchController:UISearchController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
        
        let searchTable = storyboard!.instantiateViewController(withIdentifier: "SearchTable") as! SearchTableViewController
        searchController = UISearchController(searchResultsController: searchTable)
        searchController?.searchResultsUpdater = searchTable
        
        let searchBar = searchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = searchController?.searchBar
        searchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        searchTable.mapView = mapView
        searchTable.handleMapSearchDelegate = self
    }
    
    func routePresentation(destinationPlacemark:MKPlacemark){
        
        //defining locations
        let sourcePlacemark = MKPlacemark(coordinate: currentCoordinate)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = sourceMapItem
        directionsRequest.destination = destinationMapItem
        directionsRequest.transportType = .automobile //no biking option (only car, transit, walk)
        directionsRequest.highwayPreference = .avoid
        directionsRequest.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: directionsRequest)
        
        directions.calculate { [unowned self] response, error in
            guard let response = response
            else {
                if let error = error {
                    print("Route Error: \(error)")
                }
                let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                let region = MKCoordinateRegion(center: destinationPlacemark.coordinate, span: span)
                mapView.setRegion(region, animated: true)
                return
            }
            
            routes = response.routes
            
            let alternateRoutes = Array(routes.dropFirst())
            
            for route in alternateRoutes {
                let t = route.polyline
                t.color = UIColor(ciColor: .gray)
                self.mapView.addOverlay(t)
            }
            
            guard let primaryRoute = routes.first else { return }
            let v = primaryRoute.polyline
            v.color = UIColor(ciColor: .blue)
            self.mapView.addOverlay(primaryRoute.polyline)
            let t = UIEdgeInsets(top: 20, left: 20, bottom: 350, right: 20)
            self.mapView.setVisibleMapRect(v.boundingMapRect, edgePadding: t, animated: true)

            dismiss(animated: true, completion: nil)
            let sheet = MapModuleViewController()
            sheet.selectAlternateRouteDelegate = self
            sheet.startSelectedRoute = self
            sheet.isModalInPresentation = true
            sheet.routes(router: response.routes)
            present(sheet, animated: true)
        }
    }
    func getDirections(to destination: MKMapItem) {
        let sourcePlacemark = MKPlacemark(coordinate: currentCoordinate)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = sourceMapItem
        directionsRequest.destination = destination
        directionsRequest.transportType = .walking //no biking option (only car, transit, walk)
        directionsRequest.highwayPreference = .avoid
        
        let directions = MKDirections(request: directionsRequest)
        directions.calculate { (response, _) in
            guard let response = response else { return }
            guard let primaryRoute = response.routes.first else { return }

            self.mapView.addOverlay(primaryRoute.polyline)
            
            self.locationManager.monitoredRegions.forEach({self.locationManager.stopMonitoring(for: $0)})
            
            self.steps = primaryRoute.steps
            
            for i in 0 ..< primaryRoute.steps.count {
                let step = primaryRoute.steps[i]
                print(step.instructions)
                print(step.distance)
                let region = CLCircularRegion(center: step.polyline.coordinate, radius: 20, identifier: "\(i)")
                self.locationManager.startMonitoring(for: region)
                let circle = MKCircle(center: region.center, radius: region.radius)
                self.mapView.addOverlay(circle)
            }
        }
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


extension HomeViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){

        selectedPin = placemark
        
        // clear the map
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        //add the new pin
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        mapView.addAnnotation(annotation)
                
       // let destinationPlacemarkItem = MKMapItem(placemark: placemark)
        routePresentation(destinationPlacemark: placemark)

        
        //self.getDirections(to: destinationPlacemarkItem)

    }
}

extension HomeViewController: SelectAlternateRoute {
    func showAlternate(selectedRoute:MKRoute, index: Int){
        mapView.removeOverlays(mapView.overlays)
        
        for route in routes {
            
            if route != selectedRoute
            {
                let t = route.polyline
                t.color = UIColor(ciColor: .gray)
                self.mapView.addOverlay(t)
            }
        }
            
        let v = selectedRoute.polyline
        v.color = UIColor(ciColor: .blue)
        self.mapView.addOverlay(selectedRoute.polyline)
        let t = UIEdgeInsets(top: 20, left: 20, bottom: 350, right: 20)
        self.mapView.setVisibleMapRect(v.boundingMapRect, edgePadding: t, animated: true)
    }
}

//THIS IS THE BEEFY FUNCTION FOR NAVIGATION
extension HomeViewController: StartRoute {
    func startButtonPressed(index:Int)
    {
        //CLEAR MAP
        mapView.removeOverlays(mapView.overlays)
        self.searchController?.searchBar.isHidden = true;

        let vc = NavBarViewController()
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
        
        //FIND THE ROUTE
        let routing = routes[index]



    }
}




extension HomeViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay_ = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = overlay_.color
            renderer.lineWidth = 5
            return renderer
        }
        if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.strokeColor = .red
            renderer.fillColor = .red
            renderer.alpha = 0.5
            return renderer
        }
        return MKOverlayRenderer()
    }
}
