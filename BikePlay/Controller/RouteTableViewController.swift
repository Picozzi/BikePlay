//
//  MapModuleViewController.swift
//  BikePlay
//
//  Created by Matthew Picozzi on 2023-01-25.
//
import MapboxMaps
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import Turf
import MapboxSearchUI
import MapboxCoreMaps

class RouteTableViewController: UITableViewController {
    
    var routesList : [MapboxDirections.Route] = []
    var navigationMapView: NavigationMapView!
    
    init(navigationMapView: NavigationMapView, routesList: [MapboxDirections.Route]) {
        self.routesList = routesList
        self.navigationMapView = navigationMapView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        let smallId = UISheetPresentationController.Detent.Identifier("small")
        let smallDetent = UISheetPresentationController.Detent.custom(identifier: smallId) { context in
            return 170
        }
        
        if let presentationController = presentationController as? UISheetPresentationController {
            presentationController.detents = [
                .medium(),
                smallDetent
            ]
            presentationController.prefersGrabberVisible = true
            presentationController.largestUndimmedDetentIdentifier = .medium
        }

        tableView.register(RouteTableViewCell.nib(), forCellReuseIdentifier: "RouteTableViewCell")
        drawRoute(route: routesList[0])
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routesList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let customCell = tableView.dequeueReusableCell(withIdentifier: "RouteTableViewCell", for: indexPath) as! RouteTableViewCell
        
        let route = routesList[indexPath.row]

        let distance = "\(String(Int(route.distance/1000))) km"
        let time = "\(String(Int(route.expectedTravelTime/3600))) hrs \(String(Int(route.expectedTravelTime.truncatingRemainder(dividingBy: 3600)/60))) mins"
        
        customCell.configure(distance: distance, time: time)
        customCell.cellIndex = indexPath
        return customCell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        drawRoute(route: routesList[indexPath.row])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
    }
    
    
    func drawRoute(route: MapboxDirections.Route) {
        let insets = UIEdgeInsets(top: 20, left: 20, bottom: 50, right: 20)
        let camera = navigationMapView.mapView.mapboxMap.camera(for: route.shape!.geometry, padding: insets, bearing: 0, pitch: 0)
        navigationMapView.mapView.mapboxMap.setCamera(to: camera)
        
        guard let routeShape = route.shape, routeShape.coordinates.count > 0 else { return }
        guard let mapView = navigationMapView.mapView else { return }
        let sourceIdentifier = "routeStyle"

        let feature = Feature(geometry: .lineString(LineString(routeShape.coordinates)))

        if mapView.mapboxMap.style.sourceExists(withId: sourceIdentifier) {
            try? mapView.mapboxMap.style.updateGeoJSONSource(withId: sourceIdentifier, geoJSON: .feature(feature))
        } else {
            var geoJSONSource = GeoJSONSource()
            geoJSONSource.data = .feature(feature)
            try? mapView.mapboxMap.style.addSource(geoJSONSource, id: sourceIdentifier)

            var lineLayer = LineLayer(id: "routeLayer")
            lineLayer.source = sourceIdentifier
            lineLayer.lineColor = .constant(.init(UIColor(red: 0.1897518039, green: 0.3010634184, blue: 0.7994888425, alpha: 1.0)))
            lineLayer.lineWidth = .constant(3)

            try? mapView.mapboxMap.style.addLayer(lineLayer)
        }
    }
}
