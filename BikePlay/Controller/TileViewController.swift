//
//  TileViewController.swift
//  BikePlay
//
//  Created by Matthew Picozzi on 2023-03-17.
//

import UIKit
import MapboxMaps

class TileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
 
    var offlineStorage = OfflineStorage()
    var tiles : [TileRegion] = []
        
    private let tableView : UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
    
        title = "Downloaded Tiles"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        let ancestralTabBarController = self.tabBarController  as! MainTabBarController
        offlineStorage = ancestralTabBarController.offlineStorage


        offlineStorage.tileStore.allTileRegions { result in
            switch result {
            case let .success(tileRegions):
                print(tileRegions)
                self.tiles = tileRegions

            case let .failure(error) where error is TileRegionError:
               // handleTileRegionError(error)
                print("error")

            case .failure(_):
             //   handleFailure()
                print("failure")
            }
        }
       
    }
    
    func pull()
    {
        offlineStorage.tileStore.allTileRegions { result in
            switch result {
            case let .success(tileRegions):
                print(tileRegions)

            case let .failure(error) where error is TileRegionError:
               // handleTileRegionError(error)
                print("error")

            case .failure(_):
             //   handleFailure()
                print("failure")
            }
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tiles.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        let selectedItem = self.tiles[indexPath.row]
        cell.textLabel?.text = selectedItem.id
        cell.detailTextLabel?.text = selectedItem.description
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == .delete) {
            let selectedItem = self.tiles[indexPath.row]
            tiles.remove(at: indexPath.row)
            offlineStorage.tileStore.removeTileRegion(forId: selectedItem.id)
            tableView.reloadData()
        }
    }
        
}



    
