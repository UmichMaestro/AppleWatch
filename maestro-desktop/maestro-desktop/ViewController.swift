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
    
    //box for user to type in
    @IBOutlet weak var fieldFileName: NSTextField!
    
    @IBOutlet var accelX: NSTextField!
    @IBOutlet var accelZ: NSTextField!

    var fileName = "phoneData.csv"
    var csvText = "time,RawAccelX,RawAccelZ\n"
    var newLine = "nothing"
    var timeValue = 0
    
    var timeSet = false
    var start = Double()
    var lastTime = 0.0
    
    var centralManager:CBCentralManager!
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state updated")
        print(central.state)
        
        var x = MSSynth(9, secondNumber: 10)
        let a = x?.getafromcpp()
        print(a!)
        let b = x?.getbfromcpp()
        print(b!)
        let result = x?.addfromcpp()
        print(result!)
        
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
    
    func centralManager(_ central: CBCentralManager,didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
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
    
    //called when a peripheral connects to the central
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
    {
        //look and see what kind of data the peripheral has
        peripheral.discoverServices([transferServiceUUID])
    }
    
    //called when peripheral disconnects from the central device
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("disconnected")
        
        //look for another connection
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
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)
    {
        if characteristic.uuid == transferCharacteristicUUID {
            
            if let data = characteristic.value {
                /*
                let now = CFAbsoluteTimeGetCurrent()
                let timeIn = data.to(type: Double.self)
                print("Now = \(now)")
                print("timeIn = \(timeIn)")
                print("diff = \(now - timeIn)")
                */
                if (!timeSet) {
                    start = Date().timeIntervalSince1970
                    timeSet = true
                }
                //Test for two doubles
                let contentFirst = data.prefix(upTo: 4).to(type: Float.self)
                let contentSecond = data.dropFirst(4).dropLast(8).to(type: Float.self)
                let contentThird = data.dropFirst(8).dropLast(4).to(type: Float.self)
                let contentFourth = data.dropFirst(12).to(type: Float.self)
                timeValue += 1
                //Test for 4 floats
                // display
                
                if contentFirst != nil
                {
                    accelX.stringValue = String(contentFirst)
                }
                
                if contentSecond != nil {
                    accelZ.stringValue = String(contentSecond)
                }
                
                if (timeSet){
                    var end = Date().timeIntervalSince1970
                    
                    //print("first value read because I'm scared: \(contentFirst)")
                    print("time elapsed in seconds: \(end - start)")
                    print("number of values read: \(timeValue)")
                    //print("number of (X,Y) read: \(timeValue/4)")
                    print(Double(timeValue) / (end - start))
                    newLine = "\(end - start),"
                    newLine += "\(contentFirst),"
                    newLine += "\(contentSecond)\n"
                    //add line to csv file
                    csvText.append(newLine)
                    end = Date().timeIntervalSince1970
                    //start next line
                    newLine = "\(end - start),"
                    newLine += "\(contentThird),"
                    newLine += "\(contentFourth)\n"
                    csvText.append(newLine)
                    print(newLine)
                    self.lastTime = end
                }
            } else {
                print("characteristic was nil")
            }
        }
    }
    
    //don't know when this gets called
    func peripheral(_ peripheral: CBPeripheral,didModifyServices invalidatedServices: [CBService])
    {
        print("I don't know what this should be doing")
    }
    
    //called when app appears on screen
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //creating the manager object for this device
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    //don't know what this does
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    @IBAction func stopCollection(_ sender: NSButtonCell) {
        
        //create file name based on user input
        fileName = fieldFileName.stringValue
        fileName += ".csv"
        
        //determine file path
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)

        //attempt to write data to file
        do
        {
            //debugging code
            print("trying to write file")
            print(path)

            //write the data!
            try csvText.write(to: path, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
        
        //reset these variables so we can write to another file if we wanted
        csvText = "time,RawAccelX,RawAccelZ\n"
        timeSet = false
    }
    
}

//nifty function to turn numbers into data objects and back
extension Data {
    
    init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
    
    func to<T>(type:T.Type) -> T {
        return self.withUnsafeBytes{ $0.pointee}
    }
}
