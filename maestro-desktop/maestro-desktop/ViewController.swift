//
//  ViewController.swift
//  maestro-desktop
//
//  Created by Christopher Baur on 2/8/18.
//  Copyright © 2018 Christopher Baur. All rights reserved.
//

import Cocoa
import CoreBluetooth

class ViewController: NSViewController {

    
    let ourUUID = CFUUIDCreateFromString(nil, "000" as CFString)
    let centralManager = CBCentralManager()
    
    @IBOutlet var connectedLabel: NSTextField!
    @IBOutlet var inputValue: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("before scan")
        scanForWatch()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    func scanForWatch() {
        print("in scan")
        print("after centralManager")
        if centralManager.state == .poweredOn {
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
        print("it's local name key is")
        print(advertisementData[CBAdvertisementDataLocalNameKey]!)
        if advertisementData[CBAdvertisementDataIsConnectable] != nil {
            if (advertisementData[CBAdvertisementDataServiceUUIDsKey] as AnyObject).contains(ourUUID) {
                let dataServiceArray = advertisementData[CBAdvertisementDataServiceDataKey]!
                let ourData = (dataServiceArray as AnyObject)[ourUUID!]
            }
        }
    }
}

