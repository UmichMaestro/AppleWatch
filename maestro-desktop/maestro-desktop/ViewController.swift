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
    
    
    @IBOutlet var accelX: NSTextField!
    @IBOutlet var accelY: NSTextField!
    @IBOutlet var accelZ: NSTextField!
    
    @IBOutlet var gyroX: NSTextField!
    @IBOutlet var gyroY: NSTextFieldCell!
    @IBOutlet var gyroZ: NSTextField!
    
    @IBOutlet var attitudePitch: NSTextField!
    @IBOutlet var attitudeYaw: NSTextField!
    @IBOutlet var attitudeRoll: NSTextField!
    
    var whichLabel = 0
    
    
    var centralManager:CBCentralManager!
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state updated")
        print(central.state)
        scanForPeriph()
    }
    
    func scanForPeriph() {
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
                let content = data.to(type: Double.self)
                // display
                print("before print")
                print(content)
                print("after print")
            
                switch whichLabel {
                case 0:
                    print(whichLabel)
                    attitudePitch.stringValue = String(content)
                    whichLabel += 1
                    break
                case 1:
                    print(whichLabel)
                    attitudeYaw.stringValue = String(content)
                    whichLabel += 1
                    break
                case 2:
                    print(whichLabel)
                    attitudeRoll.stringValue = String(content)
                    whichLabel += 1
                    break
                case 3:
                    print(whichLabel)
                    accelX.stringValue = String(content)
                    whichLabel += 1
                    break
                case 4:
                    print(whichLabel)
                    accelY.stringValue = String(content)
                    whichLabel += 1
                    break
                case 5:
                    print(whichLabel)
                    accelZ.stringValue = String(content)
                    whichLabel += 1
                    break
                case 6:
                    print(whichLabel)
                    gyroX.stringValue = String(content)
                    whichLabel += 1
                    break
                case 7:
                    print(whichLabel)
                    gyroY.stringValue = String(content)
                    whichLabel += 1
                    break
                case 8:
                    print(whichLabel)
                    gyroZ.stringValue = String(content)
                    whichLabel = 0
                    break
                default:
                    print("something's gone horribly wrong")
                    assert(false, "whichLabel is bigger than 8")
                }
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

extension Data {
    
    init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
    
    func to<T>(type:T.Type) -> T {
        return self.withUnsafeBytes{ $0.pointee}
    }
}
