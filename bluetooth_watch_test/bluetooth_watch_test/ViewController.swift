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
    
    var transferCharacteristic: CBMutableCharacteristic?
    var dataToSend: Data?
    var sendDataIndex: Int?
    var toSend: [Int] = [1]

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        //if the app is not on the screen, don't put yourself out there Apple watch
        peripheralManager?.stopAdvertising()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager)
    {
        print("state: \(peripheral.state)")
        //if the peripheral isn't on, this just won't work
        if(peripheral.state != .poweredOn)
        {
            return
        }
        
        print("we are powered on!")
        //create the service
        transferCharacteristic = CBMutableCharacteristic(
            type: transferCharacteristicUUID,
            properties: CBCharacteristicProperties.notify,
            value: nil,
            permissions: CBAttributePermissions.readable
        )
        // Then the service
        let transferService = CBMutableService(
            type: transferServiceUUID,
            primary: true
        )
        transferService.characteristics = [transferCharacteristic!]
        
        peripheralManager?.add(transferService)
        
        peripheralManager!.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey : [transferServiceUUID]
            ])
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?)
    {
        if let error = error {
            print("Failed... error: \(error)")
            return
        }
        
        print("Succeeded!")
    }
    
    //when someone subs to our char., start sending the data
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characterstic: CBCharacteristic)
    {
        print("central subbed to the char.")
        while true {
            sendData()
        }
    }
 
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic)
    {
        print("Central unsubbed from char.")
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager)
    {
        sendData()
    }
    
    func sendData()
    {
        let myValue = String(describing: toSend)
        var didSend = true 
        print(myValue)
        let sendingValue = myValue.data(using: String.Encoding.utf8)
        didSend = (peripheralManager?.updateValue(sendingValue!, for: transferCharacteristic!, onSubscribedCentrals: nil))!
        print("didSendValue: \(didSend )")
        
        if(!didSend)
        {
            return
        }
    }
}

