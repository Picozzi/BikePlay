//
//  BluetoothViewController.swift
//  BikePlay
//
//  Created by Matthew Picozzi on 2023-02-25.
//

import UIKit
import CoreBluetooth

//struct peripheral_list {
//    let periph : CBPeripheral
//    var isChecked : Bool
//}
//
//extension peripheral_list: Equatable {
//    static func == (lhs: peripheral_list, rhs: peripheral_list) -> Bool {
//        return
//            lhs.periph == rhs.periph &&
//            lhs.isChecked == rhs.isChecked
//    }
//}

class BluetoothViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let const_buffer_size : Int = 25
    
    var centralManager: CBCentralManager?
    var peripherals = [CBPeripheral]()
    var navigationCharacteristic:CBCharacteristic? = nil
    var weatherCharacteristic:CBCharacteristic? = nil
    var timeCharacteristic:CBCharacteristic? = nil
    
    var connectedPeripheral:CBPeripheral?
    
    let BLEService = "FFE0"
    let NavigationCharacteristicCode = "FFE1"
    let TimeCharacteristicCode = "EC02"
    let WeatherCharacteristicCode = "EC03"
    
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
        
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        NotificationCenter.default.addObserver(self, selector: #selector(sendNavigationToRPI(notification:)), name: Notification.Name("instructionNotif"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(sendDistanceToRPI(notification:)), name: Notification.Name("distanceNotif"), object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(sendNavigationToRPI(notification:)), name: Notification.Name("directionChange"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(sendWeatherToRPI(notification:)), name: Notification.Name("temperatureChange"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(sendWeatherIconToRPI(notification:)), name: Notification.Name("temperatureIconChange"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(sendTimeToRPI(notification:)), name: Notification.Name("timeChange"), object: nil) //FIX THIS
        NotificationCenter.default.addObserver(self, selector: #selector(tryDisconnectBluetooth(notification:)), name: Notification.Name("Bluetooth Disconnect Request"), object: nil) //FIX THIS
    }
    
    @objc func tryDisconnectBluetooth(notification:Notification) {
        centralManager?.cancelPeripheralConnection(connectedPeripheral!)
    }
    
    public func prepForSending(command: String, flag : String) -> String
    {
        let flagged_string = flag + command
        let numChars = flagged_string.count
        let diff = const_buffer_size - numChars
        
        let buff = String(repeating: "*", count: diff)
        
        let text = flagged_string + buff
        return text
    }
    
        
    @objc func sendNavigationToRPI(notification:Notification){
        if let instruction = notification.userInfo?["instructions"] as? String {
            
            let buffered_instruction = prepForSending(command: instruction, flag: "n:")
            //  print(instruction)

            let dataToSend = Data(buffered_instruction.utf8)
            
            if let s = String(bytes: dataToSend, encoding: .utf8) {
                print(s)
            } else {
                print("not a valid UTF-8 sequence")
            }

            if (connectedPeripheral != nil) {
                connectedPeripheral?.writeValue(dataToSend, for: navigationCharacteristic!, type: CBCharacteristicWriteType.withoutResponse)
            } else {
                print("haven't discovered device yet")
            }
            
        }
    }
    
    @objc func sendDistanceToRPI(notification:Notification){
        if let instruction = notification.userInfo?["instructions"] as? String {
            
            let buffered_instruction = prepForSending(command: instruction, flag: "d:")
            
            let dataToSend = Data(buffered_instruction.utf8)
            
            if let s = String(bytes: dataToSend, encoding: .utf8) {
                print(s)
            } else {
                print("not a valid UTF-8 sequence")
            }
            
            if (connectedPeripheral != nil) {
                connectedPeripheral?.writeValue(dataToSend, for: navigationCharacteristic!, type: CBCharacteristicWriteType.withoutResponse)
            } else {
                print("haven't discovered device yet")
            }
            
        }
    }
    
    @objc func sendWeatherIconToRPI(notification: Notification) {
        if let instruction = notification.userInfo?["instructions"] as? String {
            
            let buffered_instruction = prepForSending(command: instruction, flag: "w:")
            
            let dataToSend = Data(buffered_instruction.utf8)
            
            if let s = String(bytes: dataToSend, encoding: .utf8) {
                print(s)
            } else {
                print("not a valid UTF-8 sequence")
            }
            
            if (connectedPeripheral != nil) {
                connectedPeripheral?.writeValue(dataToSend, for: navigationCharacteristic!, type: CBCharacteristicWriteType.withoutResponse)
            } else {
                print("haven't discovered device yet")
            }
            
        }
    }
    
    
        
    @objc func sendWeatherToRPI(notification:Notification){
        if let instruction = notification.userInfo?["instructions"] as? String {
            
            let buffered_instruction = prepForSending(command: instruction, flag: "t:")
            
            let dataToSend = Data(buffered_instruction.utf8)
            
            if let s = String(bytes: dataToSend, encoding: .utf8) {
                print(s)
            } else {
                print("not a valid UTF-8 sequence")
            }
            
            if (connectedPeripheral != nil) {
                connectedPeripheral?.writeValue(dataToSend, for: navigationCharacteristic!, type: CBCharacteristicWriteType.withoutResponse)
            } else {
                print("haven't discovered device yet")
            }
            
        }
    }
        
    @objc func sendTimeToRPI(notification:Notification){
        if let instruction = notification.userInfo?["instructions"] as? String {
            
            let buffered_instruction = prepForSending(command: instruction, flag: "c:")
            
            let dataToSend = Data(buffered_instruction.utf8)
            
            if let s = String(bytes: dataToSend, encoding: .utf8) {
                print(s)
            } else {
                print("not a valid UTF-8 sequence")
            }
            
            if (connectedPeripheral != nil) {
                connectedPeripheral?.writeValue(dataToSend, for: navigationCharacteristic!, type: CBCharacteristicWriteType.withoutResponse)
            } else {
                print("haven't discovered device yet")
            }
            
        }
    }
}

extension BluetoothViewController: CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state == .poweredOn){
            self.centralManager?.scanForPeripherals(withServices: nil, options: nil)
        }
        else {
            // do something like alert the user that ble is not on
        }
    }
 
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        
        if(!peripherals.contains(peripheral) && peripheral.name != nil) {
            peripherals.append(peripheral)
            }
        
        //print(peripheral)
        tableView.reloadData()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if connectedPeripheral == peripheral {
                connectedPeripheral?.delegate = self
                print("Connected to " +  peripheral.name!)
                peripheral.discoverServices(nil);
        }
        
    }
        
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error!)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            // Handle error
            return
        }
        
        print("HI")
        // Successfully disconnected
        NotificationCenter.default.post(name: Notification.Name("BluetoothConfirmedDisconnected"), object: nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            
            for service in peripheral.services! {
                
                print("Service found with UUID: " + service.uuid.uuidString)
                
//                //device information service
//                if (service.uuid.uuidString == "180A") {
//                    peripheral.discoverCharacteristics(nil, for: service)
//                }
//
//                //GAP (Generic Access Profile) for Device Name
//                // This replaces the deprecated CBUUIDGenericAccessProfileString
//                if (service.uuid.uuidString == "1800") {
//                    peripheral.discoverCharacteristics(nil, for: service)
//                }
                
                //MY Service
                if (service.uuid.uuidString == BLEService.uppercased()) {
                    print("LOOKING")
                    peripheral.discoverCharacteristics(nil, for: service)
                }
                
            }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("HEHEHEHEHEHEHE")
            print(error)
            return
        }
        // Successfully wrote value to characteristic
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

//            //get device name
//            if (service.uuid.uuidString == "1800") {
//
//                for characteristic in service.characteristics! {
//
//                    if (characteristic.uuid.uuidString == "2A00") {
//                        peripheral.readValue(for: characteristic)
//                        print("Found Device Name Characteristic")
//                    }
//
//                }
//
//            }
//
//            if (service.uuid.uuidString == "180A") {
//
//                for characteristic in service.characteristics! {
//
//                    if (characteristic.uuid.uuidString == "2A29") {
//                        peripheral.readValue(for: characteristic)
//                        print("Found a Device Manufacturer Name Characteristic")
//                    } else if (characteristic.uuid.uuidString == "2A23") {
//                        peripheral.readValue(for: characteristic)
//                        print("Found System ID")
//                    }
//
//                }
//
//            }
            
        if (service.uuid.uuidString == BLEService.uppercased()) {
                
                for characteristic in service.characteristics! {
                    
                    if (characteristic.uuid.uuidString == NavigationCharacteristicCode.uppercased()) {
                        //we'll save the reference, we need it to write data
                        navigationCharacteristic = characteristic
                        
                        //Set Notify is useful to read incoming data async
                        peripheral.setNotifyValue(true, for: characteristic)
                        print("Found Navigation Characteristic")
                        
                        let text = peripheral.name
                        NotificationCenter.default.post(name: Notification.Name("BluetoothConnected"), object: nil, userInfo: ["instructions": text as Any])
                    }
                    
                    
                    if (characteristic.uuid.uuidString == TimeCharacteristicCode.uppercased()) {
                        //we'll save the reference, we need it to write data
                        timeCharacteristic = characteristic
                        
                        //Set Notify is useful to read incoming data async
                        peripheral.setNotifyValue(true, for: characteristic)
                        print("Found Time Characteristic")
                    }
                    
                    if (characteristic.uuid.uuidString == WeatherCharacteristicCode.uppercased()) {
                        //we'll save the reference, we need it to write data
                        weatherCharacteristic = characteristic
                        
                        //Set Notify is useful to read incoming data async
                        peripheral.setNotifyValue(true, for: characteristic)
                        print("Found Weather Characteristic")
                    }
                }
                
            }
            
        }
}
 
extension BluetoothViewController {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        
        
        let peripheral = peripherals[indexPath.row]
        
        cell.textLabel?.text = peripheral.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Nearby Devices"
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedPeripheral = peripherals[indexPath.row]
        connectedPeripheral = selectedPeripheral
        centralManager?.connect(selectedPeripheral, options: nil)
    }
}

