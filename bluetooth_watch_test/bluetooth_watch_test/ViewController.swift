//
//  ViewController.swift
//  bluetooth_watch_test
//
//  Created by Maddie Wilson on 2/9/18.
//  Copyright © 2018 Maddie Wilson. All rights reserved.
//

import UIKit
import CoreBluetooth


class ViewController: UIViewController, CBPeripheralManagerDelegate {
    
    var peripheralManager: CBPeripheralManager?
    
    let uuid = NSUUID()
    
    let identifier = NSBundle.mainBundle().bundleIdentifier!
    
    

    let peripheralManager = CBPeripheralManager()

    let watchDataUUID = [CBUUID(UUIDString: "180D")]
    
    
    
    
    /*
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager)
    {
        print("state: \(peripheral.state)")
    }
    
    let advertisementData = [CDAdvertisementDataLocalNameKey: "Test Device"]
    peripheralManager.startAdvertising(advertisementData)
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?)
    {
        if let error = error {
            print("Failed... error: \(error)")
            return
        }
        
        print("Succeeded!")
    }
    
    peripheralManager.stopAdvertising()
    
    let serviceUUID = CBUUID(string: kServiceUUID)
    let service = CBMutableService(type: serviceUUID, primary: true)
    
    let character
    */

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

