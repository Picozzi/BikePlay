//
//  OfflineStorage.swift
//  BikePlay
//
//  Created by Matthew Picozzi on 2023-03-16.
//

import Foundation
import MapboxMaps
import MapboxCoreNavigation
import MapboxNavigation

struct Region {
     var bbox: [CLLocationCoordinate2D]
     var identifier: String
 }

public class OfflineStorage {
    
    let offlineManager = OfflineManager(resourceOptions: .init(accessToken: NavigationSettings.shared.directions.credentials.accessToken ?? ""))
    
    let tileStoreConfiguration: TileStoreConfiguration = .default
    let tileStoreLocation: TileStoreConfiguration.Location = .default
    var tileStore: TileStore {
    tileStoreLocation.tileStore
    }
        
    var internetConnection : Bool?
    
    var navigationMapView = NavigationMapView()


}
