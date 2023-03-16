//
//  BluetoothViewController.swift
//  BikePlay
//
//  Created by Matthew Picozzi on 2023-02-25.
//

import UIKit
import CoreBluetooth

class BluetoothViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var bluetoothModel = BluetoothModel()
    
    var tabBar : MainTabBarController?
    
    
    private let tableView : UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Bluetooth"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        let ancestralTabBarController = self.tabBarController  as! MainTabBarController
        tabBar = ancestralTabBarController
        bluetoothModel = ancestralTabBarController.bluetoothModel
        bluetoothModel.centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
    }
}

extension BluetoothViewController: CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) { //fix this
        if (central.state == .poweredOn){
            self.bluetoothModel.centralManager?.scanForPeripherals(withServices: nil, options: nil)
        }
        else {
        }
    }
 
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        if(!bluetoothModel.availablePeripheralList.contains(peripheral) && peripheral.name != nil) {
            bluetoothModel.availablePeripheralList.append(peripheral)
            bluetoothModel.checkmarks.append(false)
            }
        
        tableView.reloadData()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if bluetoothModel.connectedPeripheral == peripheral {
                bluetoothModel.connectedPeripheral?.delegate = self
                print("Connected to " +  peripheral.name!)
                peripheral.discoverServices(nil);
        }
    }
        
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error!)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            print(error)
            return
        }
        
        // Successfully disconnected
        print("Successful Disconnect")

    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            
            for service in peripheral.services! {
                
                print("Service found with UUID: " + service.uuid.uuidString)
                
//                //device information service
//                if (service.uuid.uuidString == "180A") {
//                    peripheral.discoverCharacteristics(nil, for: service)
//                }
                
                //my service
                if (service.uuid.uuidString == bluetoothModel.BLEService.uppercased()) {
                    peripheral.discoverCharacteristics(nil, for: service)
                }
                
            }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print(error)
            return
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

        if (service.uuid.uuidString == bluetoothModel.BLEService.uppercased()) {
                
                for characteristic in service.characteristics! {
                    
                    if (characteristic.uuid.uuidString == bluetoothModel.BLECharacteristic.uppercased()) {
                        bluetoothModel.characteristic = characteristic
                        
                        //peripheral.setNotifyValue(true, for: characteristic) i dont think we need this
                        print("Found Characteristic")
                        sleep(2)
                        tabBar!.sendWeather()
                        tabBar!.sendTime()

                    }
                }
            }
        }
}
 
extension BluetoothViewController {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        
        let peripheral = bluetoothModel.availablePeripheralList[indexPath.row]
        cell.textLabel?.text = peripheral.name
        
        if indexPath == bluetoothModel.selectedIndexPath {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
            }

        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Nearby Devices"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bluetoothModel.availablePeripheralList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedPeripheral = bluetoothModel.availablePeripheralList[indexPath.row]
        let selectedCell = tableView.cellForRow(at: indexPath)
        
        //if there is no active connection
        if(bluetoothModel.connectedPeripheral == nil) {
            bluetoothModel.connectedPeripheral = selectedPeripheral
            bluetoothModel.centralManager?.connect(selectedPeripheral, options: nil)
            bluetoothModel.selectedIndexPath = indexPath
            selectedCell?.accessoryType = .checkmark
            return
        }
        
        // if they are selecting the same row again, cancel connection
        if indexPath == bluetoothModel.selectedIndexPath {
            bluetoothModel.centralManager?.cancelPeripheralConnection(bluetoothModel.connectedPeripheral!)
            bluetoothModel.connectedPeripheral = nil
            selectedCell?.accessoryType = .none
            bluetoothModel.selectedIndexPath = nil
            return
        }
        
        //if they are selecting a row and have active connection
        let oldCell = tableView.cellForRow(at: bluetoothModel.selectedIndexPath!)
        oldCell?.accessoryType = .none
        bluetoothModel.centralManager?.cancelPeripheralConnection(bluetoothModel.connectedPeripheral!)
        bluetoothModel.connectedPeripheral = selectedPeripheral
        bluetoothModel.centralManager?.connect(selectedPeripheral, options: nil)
        bluetoothModel.selectedIndexPath = indexPath
        selectedCell?.accessoryType = .checkmark
    }
}

