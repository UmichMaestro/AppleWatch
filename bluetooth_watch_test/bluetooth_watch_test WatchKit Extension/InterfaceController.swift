//
//  InterfaceController.swift
//  bluetooth_watch_test WatchKit Extension
//
//  Created by Maddie Wilson on 2/9/18.
//  Copyright © 2018 Maddie Wilson. All rights reserved.
//

import CoreBluetooth
import WatchKit
import Foundation


class InterfaceController: WKInterfaceController, CBPeripheralManagerDelegate {

    var peripheralManager: CBPeripheralManager?

    
    var transferCharacteristic: CBMutableCharacteristic?
    var dataToSend: Data?
    var sendDataIndex: Int?
    
    required override init() {
        super.init()
        peripheralManager?.delegate = self
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        peripheralManager = CBPeripheralManager()
        peripheralManager?.delegate = self
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
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
            type: transferCharacteristicUUID, properties: CBCharacteristicProperties.notify, value: nil, permissions: CBAttributePermissions.readable
        )
        
        let transferService = CBMutableService(type: transferServiceUUID, primary: true)
        
        transferService.characteristics = [transferCharacteristic!]
        
        peripheralManager?.add(transferService)
        
        peripheralManager!.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey : [transferServiceUUID] ])
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
        let myValues = ["hello", "this", "is", "a", "list"]
        var didSend = Bool()
        for myValue in myValues {
            //let myValue = "hello"
            print(myValue)
            let sendingValue = myValue.data(using: String.Encoding.utf8)
            
            didSend = (peripheralManager?.updateValue(sendingValue!, for: transferCharacteristic!, onSubscribedCentrals: nil))!
            
            print("didSendValue: \(didSend )")
        }
        print("didSendValue: \(didSend )")
        
        
        if(didSend == true)
        {
            print("message sent")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic)
    {
        print("Central unsubbed from char.")
        
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        var didSend = Bool()
        let myValue = "isReady"
        print(myValue)
        let sendingValue = myValue.data(using: String.Encoding.utf8)
        
        didSend = (peripheralManager?.updateValue(sendingValue!, for: transferCharacteristic!, onSubscribedCentrals: nil))!
        
        print("didSendValue: \(didSend )")
        
        
        if(didSend == true)
        {
            print("message sent")
        }
    }

}
