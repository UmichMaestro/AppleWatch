//
//  BluetoothManager.swift
//  maestro-phone
//
//  Created by Prakash Kumar on 11/21/18.
//  Copyright © 2018 Maestro. All rights reserved.
//

import Foundation

import UIKit
import CoreBluetooth

import CoreMotion


class BluetoothManager: NSObject, CBPeripheralManagerDelegate{
    
    //CoreMotion "controlling object"
    let motionManager = CMMotionManager()
    
    //Bluetooth "controlling object"
    var peripheralManager: CBPeripheralManager?
    
    //variables to package up data and send it via Bluetooth
    var transferCharacteristic: CBMutableCharacteristic?
    var dataToSend: Float? //used in sendData()
    var toSendIndex = 0 //shows where we are in the motion array
    var toSend: [Float] = [0, 0, 0, 0] // holds motion data
    var readyForUpdate = true
    var numberSent = 0 // testing, counts how many points we send
    var haveFirst = false // used to determine which indexes to put the data in
    var thisPacketSent = false
    
    var buffer:Buffer = Buffer()

    //end of message
    var sendingEOM = false
    
    public var handleState:((AppState)-> Void)!
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager)
    {
        print("state: \(peripheral.state)")
        //if the peripheral isn't on, we can't transfer data over BT
        if(peripheral.state != .poweredOn)
        {
            changeState(newState: .bluetooth)
            return
        }
        print("we are powered on!")
        
        //create the characteristic
        transferCharacteristic = CBMutableCharacteristic(
            type: transferCharacteristicUUID,
            properties: CBCharacteristicProperties.notify,
            value: nil,
            permissions: CBAttributePermissions.readable
        )
        //then the service
        let transferService = CBMutableService(
            type: transferServiceUUID,
            primary: true
        )
        transferService.characteristics = [transferCharacteristic!]
        
        //add the service to the list of services that the device advertises
        peripheralManager?.add(transferService)
        
        //start advertising your service to the world
        peripheralManager!.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey : [transferServiceUUID]
            ])
    }
    
    //called when the manager succesfully advertises the service
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?)
    {
        if let error = error {
            print("Failed... error: \(error)")
            return
        }
        
        print("Succeeded!")
        changeState(newState: .hello)
        self.getMotionManagerUpdates()
    }
    
    //function runs when central device unsubscribes from our characteristic
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic)
    {
        //central unsubbed from char
        motionManager.stopDeviceMotionUpdates()
    }
    
    //currently unused, but if a packet fails to send, this function will get called
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager)
    {
        sendData()
    }
    
    //does the actually work of sending the data over BT
    func sendData()
    {
        
        //currently this does not execute
        ///end of message functionality should be implemented in the future
        if sendingEOM {
            
            //send end of message string
            let didSend = peripheralManager?.updateValue(
                "EOM".data(using: String.Encoding.utf8)!,
                for: transferCharacteristic!,
                onSubscribedCentrals: nil
            )
            
            // Did it send?
            if (didSend == true) {
                
                // It did, so mark it as sent
                sendingEOM = false
                
                print("Sent: EOM")
            }
            
            return
        }
    
        
        var didSend = true
        if !thisPacketSent
        {
            

            var chunkZero = Data(from: self.buffer.items[0]) // this is accelX
            let chunkOne = Data(from: self.buffer.items[1]) // this is accelY
            let chunkTwo = Data(from: self.buffer.items[2]) // this is 2nd accelX
            let chunkThree = Data(from: self.buffer.items[3]) // this is 2nd accelY
            chunkZero.append(chunkOne)
            chunkZero.append(chunkTwo)
            chunkZero.append(chunkThree)

            didSend = peripheralManager!.updateValue(chunkZero,
                                                     for: transferCharacteristic!, onSubscribedCentrals: nil)
            
            // Check if it actually sent
            if (!didSend) {
                return
            }
            toSendIndex += 1
            numberSent += 1
            
            self.readyForUpdate = true
            self.haveFirst = false
            self.thisPacketSent = true
            self.buffer.clear()
            
            
            toSend[0] = 1000.0
            toSend[1] = 1000.0
            toSend[2] = 1000.0
            toSend[3] = 1000.0
        }
    }
    
    
    func getMotionManagerUpdates() {
        
        // operation main queue
        //let accelQueue: OperationQueue = OperationQueue.main
        let motionQueue: OperationQueue = OperationQueue.main
        
        // init interval for update (NSTimeInterval)
        self.motionManager.deviceMotionUpdateInterval = 1/100
        
        // get current gyro data
        if (self.motionManager.isDeviceMotionAvailable) {
            
            let motionHandler: CMDeviceMotionHandler = { (motionData:CMDeviceMotion?, error:Error?) -> Void in
                // errors
                if (error != nil) {
                    print("error: \(String(describing: error?.localizedDescription))")
                }else{
                    // success
                    if ((motionData) != nil && self.readyForUpdate) {
                        
                        // get accelerations values
                        let accelX = motionData?.userAcceleration.x
                        let accelY = motionData?.userAcceleration.y
                        // let accelZ = motionData?.userAcceleration.z
                        
                        let pitch = motionData?.attitude.pitch;
                        let yaw = motionData?.attitude.yaw;
                        
                        // set haveSecond to true for single sized test
                        self.buffer.addItem(item: Float(pitch!))
                        self.buffer.addItem(item: (Float(yaw!)))
                        self.buffer.addItem(item: (Float(accelY!)))
                        self.buffer.addItem(item: (Float(state.rawValue)))
                        
                        if(self.buffer.buffer_full){
                            self.readyForUpdate = false
                            self.haveFirst = false
                            self.toSendIndex = 0
                            self.thisPacketSent = false
                            self.sendData()
                        }
                        
                    }
                }
            }
            self.motionManager.startDeviceMotionUpdates(to: motionQueue, withHandler: motionHandler)
        } else {
            print("not available")
        }
        
    }
    
    func sendLatency() {
        let timeNow = CFAbsoluteTimeGetCurrent()
        let chunk = Data(from:timeNow)
        let didSend = peripheralManager!.updateValue(chunk,
                                                     for: transferCharacteristic!, onSubscribedCentrals: nil)
        if !didSend {
            return
        }
        
    }
    
    func changeState(newState:AppState){
        state = newState;
    }
    
    //called when app is open on the screen
    func load()
    {
        toSendIndex = 0
        //init BT manager object
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func start(){
        self.getMotionManagerUpdates()
    }
    
    func stop()
    {
        //if the app is not on the screen, don't advertise data over BT
        peripheralManager?.stopAdvertising()
        motionManager.stopDeviceMotionUpdates()
    }
    
    
}
