//
//  HomeViewController.swift
//  BikePlay
//
//  Created by Matthew Picozzi on 2023-01-09.
//

import UIKit
import MapKit
import CoreLocation
import AVFoundation
import WeatherKit
import Foundation

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

extension UIView {
    
    func fadeIn(_ duration: TimeInterval = 0.2, onCompletion: (() -> Void)? = nil) {
        self.alpha = 0
        self.isHidden = false
        UIView.animate(withDuration: duration,
                       animations: { self.alpha = 1 },
                       completion: { (value: Bool) in
                          if let complete = onCompletion { complete() }
                       }
        )
    }
    
    func fadeOut(_ duration: TimeInterval = 0.2, onCompletion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration,
                       animations: { self.alpha = 0 },
                       completion: { (value: Bool) in
                           self.isHidden = true
                           if let complete = onCompletion { complete() }
                       }
        )
    }
    
}

extension UIButton {
    
    func fadeInButton(_ duration: TimeInterval = 0.2, onCompletion: (() -> Void)? = nil) {
        self.alpha = 0
        self.isHidden = false
        UIView.animate(withDuration: duration,
                       animations: { self.alpha = 1 },
                       completion: { (value: Bool) in
                          if let complete = onCompletion { complete() }
                       }
        )
    }
    
    func fadeOutButton(_ duration: TimeInterval = 0.2, onCompletion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration,
                       animations: { self.alpha = 0 },
                       completion: { (value: Bool) in
                           self.isHidden = true
                           if let complete = onCompletion { complete() }
                       }
        )
    }
    
}

class HomeViewController: UIViewController {
        
    var selectedPin:MKPlacemark? = nil
    var routes:[MKRoute] = []

    var sheet:MapModuleViewController!
    
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var endRoute: UIButton!
    @IBOutlet weak var banner: UIView!
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var currentCoordinate: CLLocationCoordinate2D!
    var searchController:UISearchController? = nil
    
    //NAVIGATION STUFF
    var steps: [MKRoute.Step] = []
    var stepCounter = 0
    var selectedRoute: MKRoute?
    
    //MAYBE
    var showMapRoute = false
    var navigationStarted = false
    
    let locationDistance:Double = 500
    
    var speechsynthesizer = AVSpeechSynthesizer()
    
    var compass:MKCompassButton?
    
    var time_timer: Timer = Timer()
    var weather_timer: Timer = Timer()
    
    let notificationCenter = NotificationCenter.default
    
    @objc func buttonAction(sender: UIButton)
    {
        endOfRoute()
    }
    
    @objc func willResignActive(_ notification: Notification) {
        weather_timer.invalidate()
        time_timer.invalidate()
    }
    
    @objc func appCameToForeground(_ notification: Notification) {
        time_background_task()
        weather_background_task()
    }
    
    let weatherService = WeatherService()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationCenter.addObserver(self, selector: #selector(willResignActive), name: UIApplication.didEnterBackgroundNotification, object: nil)
                
        notificationCenter.addObserver(self, selector: #selector(appCameToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
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
        banner.isHidden = true
        endRoute.isHidden = true
        
        endRoute.tintColor = UIColor.red
        endRoute.addTarget(self, action: #selector(buttonAction), for: UIControl.Event.touchUpInside)
        
        self.time_background_task()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.weather_background_task()

        }

        
    }
    
    func time_background_task()
    {
        DispatchQueue.global(qos: .background).async { [self] in
            
            let now = Date.timeIntervalSinceReferenceDate
            let delayFraction = trunc(now) - now
            let delay = 60.0 - Double(Int(now) % 60) + delayFraction
            
            Thread.sleep(forTimeInterval: delay)
            
            self.send_time()
            
            time_timer = Timer(timeInterval: 60, repeats: true) { _ in
                self.send_time()
            }
            
            let runLoop = RunLoop.current
            runLoop.add(time_timer, forMode: .default)
            runLoop.run()
        }
    }
    
    func weather_background_task()
    {
        DispatchQueue.global(qos: .background).async { [self] in
            self.send_weather()
            
            weather_timer = Timer(timeInterval: 300, repeats: true) { _ in
                self.send_weather()
            }
            
            let runLoop = RunLoop.current
            runLoop.add(weather_timer, forMode: .default)
            runLoop.run()
        }
    }
    
    struct WeatherJSON : Codable {
        var weather: [Weather]
        var main : Main
    }
    
    struct Weather : Codable {
        var id: Int
        var main: String
        var description: String
        var icon: String
    }
    
    struct Main : Codable {
        var temp: Double
        var feels_like: Double
        var temp_min: Double
        var temp_max: Double
    }
    
    func send_time()
    {
        let date = Date()
//        let calendar = Calendar.current
//        let hour = calendar.component(.hour, from: date)
//        let minute = calendar.component(.minute, from: date)
//
//        let time_packet = String(hour) + ":" + String(minute)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let time_packet = dateFormatter.string(from: date).capitalized
        
        NotificationCenter.default.post(name: Notification.Name("timeChange"), object: nil, userInfo: ["instructions": time_packet])
        print(time_packet)
    }
    
    func send_weather()
    {
        let lat = String(currentCoordinate.latitude)
        let lon = String(currentCoordinate.longitude)
        let API_Key = "dfc0b2fb2da8198136ae02abcc493c7d"
        
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=" + lat + "&lon=" + lon + "&appid=" + API_Key + "&units=metric") else{return}

            let task = URLSession.shared.dataTask(with: url){
                data, response, error in
                
                let decoder = JSONDecoder()

                if let data = data{
                    do{
                        let tasks = try decoder.decode(WeatherJSON.self, from: data)
                            print(tasks.weather[0].main)
                            print(tasks.main.feels_like)
                            
                            let text = String(tasks.main.feels_like)
                            
                            NotificationCenter.default.post(name: Notification.Name("temperatureChange"), object: nil, userInfo: ["instructions": text])
    
                    }catch{
                        print(error)
                    }
                }
            }
        task.resume()
    }
    
    
    func endOfRoute()
    {
        stepCounter = 0
        for monitoredRegion in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: monitoredRegion)
        }
        banner.fadeOut()
        endRoute.fadeOutButton()
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        self.searchController?.searchBar.isHidden = false;
        mapView.showsCompass = true
        compass?.compassVisibility = .hidden
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
            sheet = MapModuleViewController()
            sheet.selectAlternateRouteDelegate = self
            sheet.startSelectedRoute = self
            sheet.isModalInPresentation = true
            sheet.routes(router: response.routes)
            present(sheet, animated: true)
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
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        stepCounter += 1
        if stepCounter < steps.count
        {
            let message = "In \(steps[stepCounter].distance) meters, \(steps[stepCounter].instructions)"
            let speechUtterance = AVSpeechUtterance(string: message)
            speechsynthesizer.speak(speechUtterance)
            instructionLabel.text = message
            sendNotificationToRPI(text: message)
        }
        else
        {
            print("ARRIVAL")
            stepCounter = 0
            for monitoredRegion in locationManager.monitoredRegions {
                locationManager.stopMonitoring(for: monitoredRegion)
            }
            
            //end route?
        }
    }
    
    func sendNotificationToRPI(text: String)
    {
        print("TRYING TO SEND")
        NotificationCenter.default.post(name: Notification.Name("directionChange"), object: nil, userInfo: ["instructions": text])
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
        dismiss(animated: true, completion: nil)
    
        banner.layer.cornerRadius = 5;
        banner.layer.masksToBounds = true;
        banner.fadeIn()

        endRoute.fadeInButton()
        
        //MOVE THE COMPASS
        
        mapView.showsCompass = false
        let compassButton = MKCompassButton(mapView:mapView)
        self.compass = compassButton
        compassButton.frame.origin = CGPoint(x: 20, y: 160)
        compassButton.compassVisibility = .adaptive
        view.addSubview(compassButton)
        
        //FIND THE ROUTE
        let navigatedRoute = routes[index]
        let routeSteps = navigatedRoute.steps
        self.steps = routeSteps
        
        //MAYBE ANIMATE THIS LATER - saved this tutorial to FYDP folder
        let navigatedRoutePolyline = navigatedRoute.polyline
        navigatedRoutePolyline.color = UIColor(ciColor: .red)
        self.mapView.addOverlay(navigatedRoute.polyline)
        let insets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        self.mapView.setVisibleMapRect(navigatedRoutePolyline.boundingMapRect, edgePadding: insets, animated: true)
    
        //STOP MONITORING
        for monitoredRegions in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: monitoredRegions)
        }
        
        for i in 0..<steps.count {
            let step = steps[i]
            print("STEP \(i):")
            print(step.instructions)
            print(step.distance)
            print()
            
            let region  = CLCircularRegion(center: step.polyline.coordinate, radius: 20, identifier: "\(i)")
            locationManager.startMonitoring(for: region)
            
            let circle = MKCircle(center: region.center, radius: region.radius)
            self.mapView.addOverlay(circle)
        }
        
        stepCounter += 1
        let initialMessage = "In \(steps[stepCounter].distance) meters, \(steps[stepCounter].instructions)"
        let speechUtterance = AVSpeechUtterance(string: initialMessage)
        speechsynthesizer.speak(speechUtterance)
        instructionLabel.text = initialMessage
        sendNotificationToRPI(text: initialMessage)


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
