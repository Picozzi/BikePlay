//
//  AppSettingViewController.swift
//  BikePlay
//
//  Created by Matthew Picozzi on 2023-02-24.
//
//  Setting Table View From https://www.youtube.com/watch?v=2FigkAlz1Bg
//

import UIKit

//struct Sections {
//    let title : String
//    let options : [SettingsOptionType]
//}
//
//enum SettingsOptionType {
//    case staticCell(model: SettingsOption)
//    case switchCell(model: SettingsSwitchOption)
//}
//
//struct SettingsSwitchOption {
//    let title : String
//    let icon: UIImage?
//    let iconBackgroundColor : UIColor
//    let handler : (() -> Void)
//    var isOn: Bool
//}
//
//struct SettingsOption {
//    let title : String
//    let icon: UIImage?
//    let iconBackgroundColor : UIColor
//    let handler : (() -> Void)
//}

class AppSettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let bluetoothViewController = BluetoothViewController()
    let offlineTableViewController = OfflineTableViewController()
    
    private let tableView : UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
           table.register(AppSettingTableViewCell.self, forCellReuseIdentifier: AppSettingTableViewCell.identifier)
           table.register(AppSettingSwitchTableViewCell.self, forCellReuseIdentifier: AppSettingSwitchTableViewCell.identifier)
        return table
    }()
    
    var settingsData : [SettingSections]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        let bluetoothData = SettingSections(title: "Bluetooth",
                                            cells: [SettingCell(title: "Helmet", icon: UIImage(named: "helmet"), iconBackgroundColor: .systemGreen, isOn: false, type: .normalCell) {
            
            self.navigationController?.pushViewController(self.bluetoothViewController, animated: true)
        }])
        
        let offlineData = SettingSections(title: "Offline Mode",
                                          cells: [SettingCell(title: "Download Maps", icon: UIImage(systemName: "mappin.and.ellipse"), iconBackgroundColor: .systemBlue, isOn: false, type: .normalCell) {
            
            self.navigationController?.pushViewController(self.offlineTableViewController, animated: true)
        }, SettingCell(title: "Downloaded Tiles", icon: UIImage(systemName: "icloud.and.arrow.down"), iconBackgroundColor: .systemCyan, isOn: false, type: .normalCell) {
            
            self.navigationController?.pushViewController(TileViewController(), animated: true)
        }])
        
        let screenData = SettingSections(title: "Offline Mode",
                                         cells: [SettingCell(title: "Screen Sleep", icon: UIImage(systemName: "iphone"), iconBackgroundColor: .systemOrange, isOn: false, type: .toggleCell, handler: {})])
        
        settingsData = [bluetoothData, offlineData, screenData]
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = settingsData[section]
        return section.title
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingsData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsData[section].cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = settingsData[indexPath.section].cells[indexPath.row]
    
        if cellData.type == .normalCell
        {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AppSettingTableViewCell.identifier, for: indexPath) as? AppSettingTableViewCell else { return UITableViewCell() }
            cell.label.text = cellData.title
            cell.iconImageView.image = cellData.icon
            cell.iconContainer.backgroundColor = cellData.iconBackgroundColor
            return cell
        }
        else
        {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AppSettingSwitchTableViewCell.identifier, for: indexPath) as? AppSettingSwitchTableViewCell else { return UITableViewCell() }
            cell.label.text = cellData.title
            cell.iconImageView.image = cellData.icon
            cell.iconContainer.backgroundColor = cellData.iconBackgroundColor
            cell.toggle.isOn = cellData.isOn
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellData = settingsData[indexPath.section].cells[indexPath.row]
        
        if cellData.type == .normalCell
        {
            cellData.handler()
        }
    }
}

