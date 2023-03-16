//
//  BluetoothModel.swift
//  BikePlay
//
//  Created by Matthew Picozzi on 2023-02-28.
//

import Foundation
import CoreBluetooth

public class BluetoothModel {
    let BLEService = "FFE0"
    let BLECharacteristic = "FFE1"
    let test : String = "THIS IS A TEST STRING"
    let constBufferSize : Int = 25
    
    var centralManager : CBCentralManager?
    var availablePeripheralList = [CBPeripheral]()
    var characteristic : CBCharacteristic?
    var connectedPeripheral : CBPeripheral?
    var checkmarks = [Bool]()
    var selectedIndexPath : IndexPath?
    
    public func packageDataPacket(command: String, flag : String) -> String {
            let flagged_string = flag + command
            let numChars = flagged_string.count
            let diff = constBufferSize - numChars

            let buff = String(repeating: "*", count: diff)

            let text = flagged_string + buff
            return text
        }

    public func sendToRPI(flag : String, data : String) {
            
            let buffered_instruction = packageDataPacket(command: data, flag: flag)

            let dataToSend = Data(buffered_instruction.utf8)
            
            if let s = String(bytes: dataToSend, encoding: .utf8) {
                print(s)
            } else {
                print("not a valid UTF-8 sequence")
            }

            if (connectedPeripheral != nil) {
                connectedPeripheral?.writeValue(dataToSend, for: characteristic!, type: CBCharacteristicWriteType.withoutResponse) //withoutResponseOnPico
            } else {
                print("haven't discovered device yet")
            }
        }
}

