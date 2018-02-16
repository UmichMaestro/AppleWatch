//
//  ViewController.swift
//  maestro-desktop
//
//  Created by Christopher Baur on 2/8/18.
//  Copyright © 2018 Christopher Baur. All rights reserved.
//

import Cocoa
import CoreBluetooth



var our_periph : CBPeripheral?


class ViewController: NSViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager:CBCentralManager!
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state updated")
        print(central.state)
        scanForWatch()
    }
    
    func scanForWatch() {
        print("in scan")
        if centralManager.state == CBManagerState.poweredOn {
            centralManager.scanForPeripherals(withServices:[transferServiceUUID], options:nil )
        } else {
            print("bluetooth not turned on")
        }
        print("after scan")
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        print("found a peripheral")
        
        if advertisementData[CBAdvertisementDataIsConnectable] != nil {
            print(advertisementData)
            //print(advertisementData[CBAdvertisementDataLocalNameKey]!)
            if (advertisementData[CBAdvertisementDataServiceUUIDsKey] as AnyObject).contains(transferServiceUUID) {
                self.centralManager.stopScan()
                
                our_periph = peripheral
                our_periph?.delegate = self
                central.connect(our_periph!, options: nil)
                print("connected")
                /*
                let dataServiceArray = advertisementData[CBAdvertisementDataServiceDataKey]!
                let ourData = (dataServiceArray as AnyObject)[transferServiceUUID]
                print(ourData)
                */
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([transferServiceUUID])
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("disconnected")
        
        central.scanForPeripherals(withServices: [transferServiceUUID], options: nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            let thisService = service
            
            if service.uuid == transferServiceUUID {
                peripheral.discoverCharacteristics([transferCharacteristicUUID], for: thisService)
                
                print("debug past discover")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for charactistic in service.characteristics! {
            let thisChar = charactistic as CBCharacteristic
            
            if thisChar.uuid == transferCharacteristicUUID {
                our_periph?.setNotifyValue(true, for: thisChar)
                
                print("debug after set notify")
                
                peripheral.readValue(for: thisChar)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == transferCharacteristicUUID {
            
            if let data = characteristic.value {
                let content = String(data: data, encoding: String.Encoding.utf8)
                // display
                print("before print")
                print(content!)
                print("after print")
            } else {
                print("characteristic was nil")
            }
            
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("I don't know what this should be doing")
    }
        
    
    @IBOutlet var connectedLabel: NSTextField!
    @IBOutlet var inputValue: NSTextField!
    
    let ourUUID = NSUUID()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

/*
class fiestaParrot: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    let ourUUID = CFUUIDCreateFromString(nil, "000" as CFString)
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state updated")
        scanForWatch()
    }
    
    func scanForWatch() {
        print("in scan")
        if centralManager.state == CBManagerState.poweredOn {
            centralManager.scanForPeripherals(withServices:nil, options:nil )
        } else {
            print("bluetooth not turned on")
        }
        print("after scan")
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        print("found a peripheral")
        let device = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? String
        if device?.contains("Y") == true {
            self.centralManager.stopScan()
            self.peripheral = peripheral
            self.peripheral.delegate = self
        }
        
        if advertisementData[CBAdvertisementDataIsConnectable] != nil {
            if (advertisementData[CBAdvertisementDataServiceUUIDsKey] as AnyObject).contains(ourUUID) {
                let dataServiceArray = advertisementData[CBAdvertisementDataServiceDataKey]!
                let ourData = (dataServiceArray as AnyObject)[ourUUID!]
            }
        }
    }
}

protocol fiestaParrotDelegate {
    
    init() {
    super.init()
    }
    
    func didGet(reading: Reading)
}

class Reading {
    func doNothing() {
        if "i" == "eye" {
            let eye = "i"
        }
    }
}
 */
