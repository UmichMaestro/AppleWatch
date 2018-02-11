//
//  ViewController.swift
//  maestro-desktop
//
//  Created by Christopher Baur on 2/8/18.
//  Copyright © 2018 Christopher Baur. All rights reserved.
//

import Cocoa
import CoreBluetooth

class ViewController: NSViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager:CBCentralManager!
    //var peripheral = CBPeripheral()
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state updated")
        print(central.state)
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
            //self.peripheral = peripheral
            //self.peripheral.delegate = self
        }
        
        if advertisementData[CBAdvertisementDataIsConnectable] != nil {
            print(advertisementData[CBAdvertisementDataLocalNameKey])
            /*
            if (advertisementData[CBAdvertisementDataServiceUUIDsKey] as AnyObject).contains(ourUUID) {
                let dataServiceArray = advertisementData[CBAdvertisementDataServiceDataKey]!
                let ourData = (dataServiceArray as AnyObject)[ourUUID]
            }
            */
        }
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
