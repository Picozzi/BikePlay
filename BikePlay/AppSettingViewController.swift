//
//  AppSettingViewController.swift
//  BikePlay
//
//  Created by Matthew Picozzi on 2023-02-24.
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
        
        models.append(Sections(title: "General",
                               options: [
                                .staticCell(model: SettingsOption(title: "YSL", icon: UIImage(systemName: "house"), iconBackgroundColor: .systemMint) {
                                    
                                    let bvc = BluetoothViewController()
                                    self.navigationController?.pushViewController(bvc, animated: true)
                                    
                                    
                                    
                                }),
                                .staticCell(model: SettingsOption(title: "Bluetooth", icon: UIImage(systemName: "house"), iconBackgroundColor: .systemMint) {
                                    print("TAPPED BLE")
                                })]
                              ))
        
        models.append(Sections(title: "Second General",
                               options: [
                                .staticCell(model: SettingsOption(title: "VV", icon: UIImage(systemName: "house"), iconBackgroundColor: .systemMint) {
                                    
                                    print("TAPPED VV")
                                }),
                                .staticCell(model: SettingsOption(title: "XYZ", icon: UIImage(systemName: "house"), iconBackgroundColor: .systemMint) {
                                    
                                    print("TAPPED XYZ")
                                })]
                              ))
        models.append(Sections(title: "Second General",
                               options: [
                                .switchCell(model: SettingsSwitchOption(title: "HEHE", icon: UIImage(systemName: "house"), iconBackgroundColor: .systemRed, handler: {print("HI")}, isOn: false))]
                            
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
