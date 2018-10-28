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
    
    @IBOutlet weak var fieldFileName: NSTextField!
    
    @IBOutlet var accelX: NSTextField!
    @IBOutlet var accelY: NSTextField!
    
    var alg_manager:AlgorithmManager = AlgorithmManager()
    
    var whichLabel = 0

    var fileName = "phoneData.csv"
    var csvText = "time,RawAccelX,RawAccelY\n"
    var newLine = "nothing"
    var timeValue = 0
    
    var timeSet = false
    var start = Double()
    var lastTime = 0.0
    
    var sound_produced = false
    var cut_off_sound = false
    
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
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        print("dissapear")
        cleanUp()
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
                
                accelX.stringValue = String(contentFirst)
                accelY.stringValue = String(contentSecond)
                
                let pitch = contentFirst;
                let yaw = contentSecond;

                if(alg_manager.cutoffState == AlgorithmManager.State.action_point){
                    if(!sound_produced)
                    {
                        print("we should hear sound right here")
                        sound_produced = true
                        let dynamic = alg_manager.handleDynamic(current_range: alg_manager.currentPitchRange);
                        
                        let dynLevel:Double = dynamic.rawValue;
                        
                        startSound()
                        changeVolume(dynLevel)
                    }
                    
                    
                }
                if(alg_manager.cutoffState == AlgorithmManager.State.cutoff){
                    if(!cut_off_sound)
                    {
                        print("DONT make another sound")
                        cut_off_sound = true
                        cutoff()

                    }
                    
                }
                
                if (timeSet){
                    alg_manager.update(pitch:pitch, yaw:yaw);
                    
                    var end = Date().timeIntervalSince1970
                    
                    //print("first value read because I'm scared: \(contentFirst)")
                    //print("time elapsed in seconds: \(end - start)")
                    //print("number of values read: \(timeValue)")
                    //print("number of (X,Y) read: \(timeValue/4)")
                    //print(Double(timeValue) / (end - start))
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
                    //print(newLine)
                    self.lastTime = end
                }
            } else {
                //print("characteristic was nil")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("I don't know what this should be doing")
    }
    
    let ourUUID = NSUUID()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        //setup for synth engine
        
        setup()
        print(" I setup")
        //setup()

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    @IBAction func stopCollection(_ sender: NSButtonCell) {
        
        //let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        fileName = fieldFileName.stringValue
        fileName += ".csv"
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
        do {
            print("trying to write file")
            try csvText.write(to: path, atomically: true, encoding: String.Encoding.utf8)
            print(path)
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
    }


    @IBAction func startGesture(_ sender: NSButton){
        sound_produced = false
        cut_off_sound = false
        alg_manager.startGesture();
    }
    
    @IBAction func start_sound(_ sender: Any) {
        print("start button works")
        //startSound()
        
        startSound()
        
        //sleep(1)
        
        //cutoff()
        
    }
    
    
    @IBAction func end_sound(_ sender: Any)
    {
        print("end button works")

        cutoff()
        //cleanUp()
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
