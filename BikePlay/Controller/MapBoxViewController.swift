import MapboxMaps
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import Turf
import MapKit

class MapBoxViewController: UIViewController {

    var navigationMapView: NavigationMapView!
    var navigationViewController: NavigationViewController!
    var routeOptions: NavigationRouteOptions?
    var routeResponse: RouteResponse?
    var startButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationMapView = NavigationMapView(frame: view.bounds)
        navigationMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(navigationMapView)

        let navigationViewportDataSource = NavigationViewportDataSource(navigationMapView.mapView, viewportDataSourceType: .raw)
        navigationMapView.navigationCamera.viewportDataSource = navigationViewportDataSource

        navigationMapView.userLocationStyle = .puck2D()

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        navigationMapView.addGestureRecognizer(longPress)

        displayStartButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        startButton.layer.cornerRadius = startButton.bounds.midY
        startButton.clipsToBounds = true
        startButton.setNeedsDisplay()
    }

    func displayStartButton() {
        startButton = UIButton()

        startButton.setTitle("Start Navigation", for: .normal)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.backgroundColor = .blue
        startButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        startButton.addTarget(self, action: #selector(tappedButton(sender:)), for: .touchUpInside)
        startButton.isHidden = true
        view.addSubview(startButton)

        startButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        startButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        view.setNeedsLayout()
    }

    @objc func didLongPress(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }

        let point = sender.location(in: navigationMapView)
        let coordinate = navigationMapView.mapView.mapboxMap.coordinate(for: point)

        if let origin = navigationMapView.mapView.location.latestLocation?.coordinate {
            calculateRoute(from: origin, to: coordinate)
        } else {
            print("Failed to get user location, make sure to allow location access for this application.")
        }
    }

    @objc func tappedButton(sender: UIButton) {
        guard let routeResponse = routeResponse, let navigationRouteOptions = routeOptions else { return }

        navigationViewController = NavigationViewController(for: routeResponse, routeIndex: 0,
                                                                routeOptions: navigationRouteOptions)

        let indexedRouteResponse = IndexedRouteResponse(routeResponse: routeResponse, routeIndex: 0)
        let navigationService = MapboxNavigationService(indexedRouteResponse: indexedRouteResponse,
                                                        customRoutingProvider: NavigationSettings.shared.directions,
                                                        credentials: NavigationSettings.shared.directions.credentials)

        let topBanner = TopBanner()
        let navigationOptions = NavigationOptions(navigationService: navigationService, topBanner: topBanner)
        let navigationViewController = NavigationViewController(for: indexedRouteResponse, navigationOptions: navigationOptions)


        let parentSafeArea = navigationViewController.view.safeAreaLayoutGuide

        topBanner.view.topAnchor.constraint(equalTo: parentSafeArea.topAnchor).isActive = true

        navigationViewController.modalPresentationStyle = .fullScreen

        navigationViewController.floatingButtons = []
        navigationViewController.showsSpeedLimits = false







        present(navigationViewController, animated: true, completion: nil)
    }

    func calculateRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {


        let origin = Waypoint(coordinate: origin, coordinateAccuracy: -1, name: "Start")
        let destination = Waypoint(coordinate: destination, coordinateAccuracy: -1, name: "Finish")

        let routeOptions = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .automobileAvoidingTraffic)

        Directions.shared.calculate(routeOptions) { [weak self] (session, result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                guard let route = response.routes?.first, let strongSelf = self else {
                    return
                }

                strongSelf.routeResponse = response
                strongSelf.routeOptions = routeOptions

                strongSelf.startButton?.isHidden = false

                strongSelf.drawRoute(route: route)

                strongSelf.navigationMapView.showWaypoints(on: route)
            }
        }
    }

    func drawRoute(route: Route) {
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

class TopBanner: ContainerViewController {
    
    var previouslySentDistance : String!
    
    private lazy var instructionsBannerTopOffsetConstraint = {
    return instructionsBannerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
    }()
    private lazy var centerOffset: CGFloat = calculateCenterOffset(with: view.bounds.size)
    private lazy var instructionsBannerCenterOffsetConstraint = {
    return instructionsBannerView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0)
    }()
    private lazy var instructionsBannerWidthConstraint = {
    return instructionsBannerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9)
    }()

    lazy var instructionsBannerView: InstructionsBannerView = {
    let banner = InstructionsBannerView()
    banner.translatesAutoresizingMaskIntoConstraints = false
    banner.heightAnchor.constraint(equalToConstant: 100.0).isActive = true
    banner.layer.cornerRadius = 25
    banner.layer.opacity = 0.75
    banner.separatorView.isHidden = true
    return banner
    }()

    override func viewDidLoad() {
    view.addSubview(instructionsBannerView)

    setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    updateConstraints()
    }

    private func setupConstraints() {
    instructionsBannerCenterOffsetConstraint.isActive = true
    instructionsBannerTopOffsetConstraint.isActive = true
    instructionsBannerWidthConstraint.isActive = true
    }

    private func updateConstraints() {
    instructionsBannerCenterOffsetConstraint.constant = centerOffset
    }

    private func calculateCenterOffset(with size: CGSize) -> CGFloat {
    return (size.height < size.width ? -size.width / 5 : 0)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    centerOffset = calculateCenterOffset(with: size)
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    updateConstraints()
    }
    
    public func distancePrep(dist : String)
    {
        if dist != previouslySentDistance
        {
            let dist1 = dist.components(separatedBy: .whitespaces)
            let dist2 = dist1.joined()
    
            NotificationCenter.default.post(name: Notification.Name("distanceNotif"), object: nil, userInfo: ["instructions": dist2])
            previouslySentDistance = dist
        }
    }
    
    public func iconPrep(typeOfDirection : String, typeOfManeuver : String)
    {
        var direction = ""
        var instruction = ""
        
        switch typeOfDirection
        {
        case "sharp right":
            direction = "right"
            
        case "right":
            direction = "right"
        
        case "slight right":
            direction = "right"
            
        case "straight ahead":
            direction = "forward"
            
        case "slight left":
            direction = "left"
            
        case "sharp left":
            direction = "left"
            
        case "left":
            direction = "left"
        
        case "uturn":
            direction = "uturn"
       
        default:
            direction = "forward"
        }
        
        switch typeOfManeuver
        {
        case "depart":
            instruction = "depart"
            
        case "turn":
            instruction = direction
        
        case "continue":
            instruction = "forward"
            
        case "new name":
            instruction = direction
            
        case "merge":
            instruction = direction

        case "on ramp":
            instruction = direction

        case "off ramp":
            instruction = direction

        case "fork":
            instruction = direction
        
        case "end of road":
            instruction = direction
            
        case "use lane":
            instruction = direction
        
        case "roundabout":
            instruction = direction
            
        case "rotary":
            instruction = direction
            
        case "roundabout turn":
            instruction = direction
            
        case "exit roundabout":
            instruction = direction

        case "exit rotary":
            instruction = direction

        case "notification":
            instruction = "warning"
            
        case "arrive":
            instruction = "arrive"
        
        default:
            instruction = "forward"
        }
      
        NotificationCenter.default.post(name: Notification.Name("instructionNotif"), object: nil, userInfo: ["instructions": instruction])
    }
    
    

    public func navigationService(_ service: NavigationService, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
    // pass updated data to sub-views which also implement `NavigationServiceDelegate`
        instructionsBannerView.updateDistance(for: progress.currentLegProgress.currentStepProgress)
        distancePrep(dist: instructionsBannerView.distanceLabel.text ?? "default")
    }

    public func navigationService(_ service: NavigationService, didPassVisualInstructionPoint instruction: VisualInstructionBanner, routeProgress: RouteProgress) {
        instructionsBannerView.update(for: instruction)
        
        
        iconPrep(typeOfDirection: instruction.primaryInstruction.maneuverDirection?.rawValue ?? "default", typeOfManeuver: instruction.primaryInstruction.maneuverType?.rawValue ?? "default")

    }

    public func navigationService(_ service: NavigationService, didRerouteAlong route: Route, at location: CLLocation?, proactive: Bool) {
    instructionsBannerView.updateDistance(for: service.routeProgress.currentLegProgress.currentStepProgress)
    }
}
