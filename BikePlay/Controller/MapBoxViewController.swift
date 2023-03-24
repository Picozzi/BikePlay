import MapboxMaps
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import Turf
import MapKit
import MapboxSearchUI
import Network

class MapBoxViewController : UIViewController, SearchControllerDelegate {

    //Search
    let searchController = MapboxSearchController()

    //Navigation
    var navigationMapView: NavigationMapView!
    var navigationViewController: NavigationViewController!
    var routeOptions: NavigationRouteOptions?
    var routeResponse: RouteResponse?

    let notificationCenter = NotificationCenter.default
    var panelController : MapboxPanelController!
    
    //Models
    var bluetoothModel = BluetoothModel()
    var offlineStorage = OfflineStorage()

    var canDismiss : Bool = false

    //Alternate Routes
    var sheet:RouteTableViewController!

    var internetConnection : Bool?

    override func viewDidLoad() {
        
        let ancestralTabBarController = self.tabBarController  as! MainTabBarController
        bluetoothModel = ancestralTabBarController.bluetoothModel
        offlineStorage = ancestralTabBarController.offlineStorage

        navigationMapView = offlineStorage.navigationMapView
        
        navigationMapView.frame = view.bounds
        navigationMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(navigationMapView)

        let navigationViewportDataSource = NavigationViewportDataSource(navigationMapView.mapView, viewportDataSourceType: .raw)
        navigationMapView.navigationCamera.viewportDataSource = navigationViewportDataSource
        navigationMapView.userLocationStyle = .puck2D()
        
        MapboxCoreNavigation.NavigationSettings.shared.initialize(with: MapboxCoreNavigation.NavigationSettings.Values(tileStoreConfiguration: offlineStorage.tileStoreConfiguration, routingProviderSource: .hybrid))

        searchController.delegate = self
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        navigationMapView.addGestureRecognizer(longPress)

        notificationCenter.addObserver(self, selector: #selector(navigationButtonClicked(notification:)), name: Notification.Name("navigationButtonClicked"), object: nil)
        
        let panelController = MapboxPanelController(rootViewController: searchController)
        self.panelController = panelController
            
        internetConnection = offlineStorage.internetConnection

        if (internetConnection ?? false)
        {
            addChild(panelController)
        }
        else
        {
            showDownloadedTiles()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        internetConnection = offlineStorage.internetConnection

        if (internetConnection ?? false)
        {
            self.offlineStorage.tileStore.allTileRegions { result in
                switch result {
                case let .success(tileRegions):
                    for tileRegion in tileRegions
                    {
                        try? self.navigationMapView.mapView.mapboxMap.style.removeLayer(withId: tileRegion.id)
                        try? self.navigationMapView.mapView.mapboxMap.style.removeLayer(withId: tileRegion.id)
                    }
                case .failure(_):
                    print("failure")
                }
            }
            addChild(panelController)
        }
        else
        {
            panelController.view.removeFromSuperview()
            showDownloadedTiles()
        }
    }


    func showDownloadedTiles()
    {
        offlineStorage.tileStore.allTileRegions { result in
            switch result {
            case let .success(tileRegions):
                for tileRegion in tileRegions
                {
                    self.offlineStorage.tileStore.tileRegionGeometry(forId: tileRegion.id, completion: { result in
                        switch result {
                        case let .success(geometry):

                            self.addRegionBoxLine(tile: tileRegion, data: geometry)
                        case let .failure(error) where error is MapboxMaps.TileRegionError:
                            print(error)
                        case .failure(_):
                            print("failure")
                        }
                    })
                }

            case let .failure(error) where error is MapboxMaps.TileRegionError:
                print("error")

            case .failure(_):
                print("failure")
            }
        }
    }

    func addRegionBoxLine(tile : TileRegion, data : MapboxMaps.Geometry) {

        guard let style = navigationMapView?.mapView.mapboxMap.style else { return }

            do {
                let identifier = tile.id
                print(identifier)
                var source = GeoJSONSource()
                source.data = .geometry(data.geometry)
                try style.addSource(source, id: identifier)
            } catch {
                print("Error \(error.localizedDescription) occured while adding box for region boundary.")
            }
        do{
            let identifier = tile.id
                var layer = LineLayer(id: identifier)
                layer.source = identifier
                layer.lineWidth = .constant(3.0)
                layer.lineColor = .constant(.init(.red))
                try style.addPersistentLayer(layer)
            } catch {
                print("Error \(error.localizedDescription) occured while adding box for region boundary.")
            }
        }

    @objc func didLongPress(_ sender: UILongPressGestureRecognizer) {

            if canDismiss {
                dismiss(animated: true)
            }
              guard sender.state == .began else { return }

              let point = sender.location(in: navigationMapView)
              let coordinate = navigationMapView.mapView.mapboxMap.coordinate(for: point)

              if let origin = navigationMapView.mapView.location.latestLocation?.coordinate {
                  
                  internetConnection = offlineStorage.internetConnection
                  if(internetConnection ?? false)
                  {
                      print("CALCULATING ONLINE")
                      calculateRoute(from: origin, to: coordinate)
                  }
                  else
                  {
                      print("CALCULATING OFFLINE")
                      calculateOfflineRoute(from: origin, to: coordinate)
                  }
              } else {
                  print("Failed to get user location, make sure to allow location access for this application.")
              }
    }

    func showResults(_ results: [SearchResult]) {
        let annotations = results.map { searchResult -> PointAnnotation in
            var annotation = PointAnnotation(point: Point(searchResult.coordinate))
            annotation.image = .init(image: UIImage(named: "red_pin")!, name: "red_pin")
            return annotation
        }
        navigationMapView.pointAnnotationManager?.annotations = annotations
    }

    func searchResultSelected(_ searchResult: SearchResult) {
        canDismiss = true
        if let origin = navigationMapView.mapView.location.latestLocation?.coordinate {
            calculateRoute(from: origin, to: searchResult.coordinate)
        } else {
            print("Failed to get user location, make sure to allow location access for this application.")
        }
    }

    func userFavoriteSelected(_ userFavorite: FavoriteRecord) {
        canDismiss = true
        if let origin = navigationMapView.mapView.location.latestLocation?.coordinate {
            calculateRoute(from: origin, to: userFavorite.coordinate)
        } else {
            print("Failed to get user location, make sure to allow location access for this application.")
        }

    }

    func categorySearchResultsReceived(category: MapboxSearchUI.SearchCategory, results: [MapboxSearch.SearchResult]) {
        canDismiss = true
        try? navigationMapView.mapView.mapboxMap.style.removeLayer(withId: "routeLayer")
        try? navigationMapView.mapView.mapboxMap.style.removeSource(withId: "routeStyle")
        showResults(results)
    }

    func calculateRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
         canDismiss = true
         let origin = Waypoint(coordinate: origin, coordinateAccuracy: -1, name: "Start")
         let destination = Waypoint(coordinate: destination, coordinateAccuracy: -1, name: "Finish")

         let routeOptions = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .automobile)

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

                 self?.navigationMapView.pointAnnotationManager?.annotations = []
                 strongSelf.navigationMapView.showWaypoints(on: route)
                 strongSelf.presentModal()
             }
         }
     }
    
    func calculateOfflineRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
         canDismiss = true
         let origin = Waypoint(coordinate: origin, coordinateAccuracy: -1, name: "Start")
         let destination = Waypoint(coordinate: destination, coordinateAccuracy: -1, name: "Finish")

         let routeOptions = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .cycling)

        Directions.shared.calculateOffline(options: routeOptions) { [weak self] (session, result) in
             switch result {
             case .failure(let error):
                 print(error.localizedDescription)
             case .success(let response):
                 guard let route = response.routes?.first, let strongSelf = self else {
                     return
                 }

                 strongSelf.routeResponse = response
                 strongSelf.routeOptions = routeOptions

                 self?.navigationMapView.pointAnnotationManager?.annotations = []
                 strongSelf.navigationMapView.showWaypoints(on: route)
                 strongSelf.presentModal()
             }
         }
     }
    
    func presentModal() {
        sheet = RouteTableViewController(navigationMapView: navigationMapView, routesList: (routeResponse?.routes)!)
        present(sheet, animated: true)
    }

    @objc func navigationButtonClicked(notification:Notification) {
        if let instruction = notification.userInfo?["instructions"] as? Int {
            startedNavigation(selectedIndex: instruction)
        }
    }

    func startedNavigation(selectedIndex : Int) {
            dismiss(animated: true)
            guard let routeResponse = routeResponse, let navigationRouteOptions = routeOptions else { return }

            let indexedRouteResponse = IndexedRouteResponse(routeResponse: routeResponse, routeIndex: selectedIndex)
            let navigationService = MapboxNavigationService(indexedRouteResponse: indexedRouteResponse,
                                                            customRoutingProvider: NavigationSettings.shared.directions,
                                                            credentials: NavigationSettings.shared.directions.credentials)

            let topBanner = TopBanner(bluetooth: bluetoothModel)
            let navigationOptions = NavigationOptions(navigationService: navigationService, topBanner: topBanner)
            let navigationViewController = NavigationViewController(for: indexedRouteResponse, navigationOptions: navigationOptions)

            let parentSafeArea = navigationViewController.view.safeAreaLayoutGuide

            topBanner.view.topAnchor.constraint(equalTo: parentSafeArea.topAnchor).isActive = true

            navigationViewController.modalPresentationStyle = .fullScreen

            navigationViewController.floatingButtons = []
            navigationViewController.showsSpeedLimits = false
            present(navigationViewController, animated: true, completion: nil)
        }
}
