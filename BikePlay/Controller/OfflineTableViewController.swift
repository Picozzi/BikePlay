//
//  OfflineViewController.swift
//  BikePlay
//
//  Created by Matthew Picozzi on 2023-03-16.
//
import UIKit
import MapKit

import MapboxMaps
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import MapboxNavigationNative

class OfflineTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var resultArray:[MKMapItem] = []
    var searchController = UISearchController()
    
    var locationModel = LocationModel()
    var offlineStorage = OfflineStorage()
    
    let tableView : UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        let searchBar = searchController.searchBar
        
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        tableView.delegate = self
        tableView.dataSource = self
        
        let ancestralTabBarController = self.tabBarController  as! MainTabBarController
        locationModel = ancestralTabBarController.locationModel
        offlineStorage = ancestralTabBarController.offlineStorage
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        let selectedItem = self.resultArray[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = selectedItem.thoroughfare?.description
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedItem = self.resultArray[indexPath.row].placemark
        
        downloadTile(name: selectedItem.name ?? "default", coordinates: selectedItem.coordinate)
        
    }
    
    func downloadTile(name:String, coordinates: CLLocationCoordinate2D)
    {
        let tempRegion = MKCoordinateRegion(center: coordinates, latitudinalMeters: 1e4, longitudinalMeters: 1e4);
        var northWest = CLLocationCoordinate2D()
        var southEast = CLLocationCoordinate2D()
        var northEast = CLLocationCoordinate2D()
        var southWest = CLLocationCoordinate2D()
        
        southEast.latitude = tempRegion.center.latitude - 0.5 * tempRegion.span.latitudeDelta;
        southEast.longitude = tempRegion.center.longitude + 0.5 * tempRegion.span.longitudeDelta;
        
        southWest.latitude = tempRegion.center.latitude - 0.5 * tempRegion.span.latitudeDelta;
        southWest.longitude = tempRegion.center.longitude - 0.5 * tempRegion.span.longitudeDelta;
        
        northWest.latitude = tempRegion.center.latitude + 0.5 * tempRegion.span.latitudeDelta;
        northWest.longitude = tempRegion.center.longitude - 0.5 * tempRegion.span.longitudeDelta;
        
        northEast.latitude = tempRegion.center.latitude + 0.5 * tempRegion.span.latitudeDelta;
        northEast.longitude = tempRegion.center.longitude + 0.5 * tempRegion.span.longitudeDelta;
        
        let region = Region(bbox: [northWest, northEast, southEast, southWest], identifier: name)
        
        guard let styleOptions = StylePackLoadOptions(glyphsRasterizationMode: .ideographsRasterizedLocally, metadata: nil) else { return }
        
        offlineStorage.offlineManager.loadStylePack(for: .streets, loadOptions: styleOptions, completion: { result in
            
            switch result {
            case .success(let stylePack):
                print("Style pack \(stylePack.styleURI) downloaded!")
                
                
                self.tileRegionLoadOptions(for: region) { [weak self] loadOptions in
                    
                    guard let self = self, let loadOptions = loadOptions else { return }
                    
                    let tileRegionId = region.identifier
                    
                    let tileRegionCancelable = self.offlineStorage.tileStore.loadTileRegion(forId: tileRegionId, loadOptions: loadOptions) { _ in } completion: { result in
                        switch result {
                        case let .success(tileRegion):
                            print("Downloaded \(tileRegion)")
                        case let .failure(error):
                            if case TileRegionError.canceled = error {
                                print("Cancelled Download")
                            } else {
                                print(error)
                            }
                        }
                    }
                }
            case .failure(let error):
                print("Error while downloading style pack: \(error).")
            }
        })
    }
    
    func tileRegionLoadOptions(for region: Region, completion: @escaping (TileRegionLoadOptions?) -> Void) {
        let tilesetDescriptorOptions = TilesetDescriptorOptions(styleURI: .streets, zoomRange: 0...16)
        let mapsDescriptor = offlineStorage.offlineManager.createTilesetDescriptor(for: tilesetDescriptorOptions)
        TilesetDescriptorFactory.getLatest { navigationDescriptor in
            completion(
                TileRegionLoadOptions(
                    geometry: Polygon([region.bbox]).geometry,
                    descriptors: [ mapsDescriptor, navigationDescriptor ],
                    metadata: nil,
                    acceptExpired: true,
                    networkRestriction: .none)
            )
        }
    }
}

extension OfflineTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text else { return }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        let region = MKCoordinateRegion(center: locationModel.location?.coordinate ?? CLLocationCoordinate2D(latitude: 50.714691, longitude: 4.399100), span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
            request.region = region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.resultArray = response.mapItems
            self.tableView.reloadData()
            }
        }
    
}
