//
//  AppSettingViewController.swift
//  BikePlay
//
//  Created by Matthew Picozzi on 2023-02-24.
//
//  Setting Table View From https://www.youtube.com/watch?v=2FigkAlz1Bg
//

import UIKit

struct Sections {
    let title : String
    let options : [SettingsOptionType]
}

enum SettingsOptionType {
    case staticCell(model: SettingsOption)
    case switchCell(model: SettingsSwitchOption)
}

struct SettingsSwitchOption {
    let title : String
    let icon: UIImage?
    let iconBackgroundColor : UIColor
    let handler : (() -> Void)
    var isOn: Bool
}

struct SettingsOption {
    let title : String
    let icon: UIImage?
    let iconBackgroundColor : UIColor
    let handler : (() -> Void)
}

class AppSettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let bluetoothViewController = BluetoothViewController()
    let offlineTableViewController = OfflineTableViewController()
 //   let tileViewController = TileViewController()
    
    private let tableView : UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(AppSettingTableViewCell.self, forCellReuseIdentifier: AppSettingTableViewCell.identifier)
        table.register(AppSettingSwitchTableViewCell.self, forCellReuseIdentifier: AppSettingSwitchTableViewCell.identifier)
        return table
    }()
    
    var models = [Sections]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        title = "Settings"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
    }
    
    func configure() {
        
        models.append(Sections(title: "Bluetooth",
                               options: [
                                .staticCell(model: SettingsOption(title: "Helmet", icon: UIImage(named: "bike"), iconBackgroundColor: .systemGreen) {
                                    
                                    self.navigationController?.pushViewController(self.bluetoothViewController, animated: true)
                                    
                                })]
                              ))
        
        models.append(Sections(title: "Offline Mode",
                               options: [
                                .staticCell(model: SettingsOption(title: "Download Maps", icon: UIImage(systemName: "mappin.and.ellipse"), iconBackgroundColor: .systemBlue) {
                                    
                                    self.navigationController?.pushViewController(self.offlineTableViewController, animated: true)
                                    
                                }), .staticCell(model: SettingsOption(title: "Downloaded Tiles", icon: UIImage(systemName: "icloud.and.arrow.down"), iconBackgroundColor: .systemCyan) {
                                    
                                    self.navigationController?.pushViewController(TileViewController(), animated: true)
                                    
                                })]
                              ))
  
        models.append(Sections(title: "Other",
                               options: [
                                .switchCell(model: SettingsSwitchOption(title: "Screen Sleep", icon: UIImage(systemName: "iphone"), iconBackgroundColor: .systemOrange, handler: {}, isOn: false))]
                              ))

        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let model = models[section]
        return model.title
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section].options[indexPath.row]
        
        switch model.self {
            case .staticCell(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AppSettingTableViewCell.identifier, for: indexPath) as? AppSettingTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: model)
            return cell
            case .switchCell(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AppSettingSwitchTableViewCell.identifier, for: indexPath) as? AppSettingSwitchTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: model)
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = models[indexPath.section].options[indexPath.row]
        switch type.self {
        case .staticCell(let model):
            model.handler()
        case .switchCell(let model):
            model.handler()
        }
        
    }
    
}
