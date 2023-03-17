//
//  OfflineStorage.swift
//  BikePlay
//
//  Created by Matthew Picozzi on 2023-03-16.
//

import Foundation
import MapboxMaps
import MapboxCoreNavigation

public class OfflineStorage {
    
    let offlineManager = OfflineManager(resourceOptions: .init(accessToken: NavigationSettings.shared.directions.credentials.accessToken ?? ""))
    
    let tileStoreConfiguration: TileStoreConfiguration = .default
    let tileStoreLocation: TileStoreConfiguration.Location = .default
    var tileStore: TileStore {
    tileStoreLocation.tileStore
    }
    
}
