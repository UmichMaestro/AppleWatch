//
//  ViewController.swift
//  bluetooth_watch_test
//
//  Created by Maddie Wilson on 2/9/18.
//  Copyright © 2018 Maddie Wilson. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreMotion

class ViewController: UIViewController, CBPeripheralManagerDelegate {
    
    let motionManager = CMMotionManager()
    
    var peripheralManager: CBPeripheralManager?
    
    var transferCharacteristic: CBMutableCharacteristic?
    var dataToSend: Double?
    var sendDataIndex = Int(0)
    var toSendIndex = Int(0)
    var toSend: [Double] = [0, 0, 0, 0, 0, 0, 0, 0, 0]
    var numberSent = Int(0)
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        toSendIndex = 0
        numberSent = 0
        
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
        
        getMotionManagerUpdates()
        
        /*
        // Get data
        dataToSend = toSend[toSendIndex]
            //.data(using: String.Encoding.utf8)
        
        // Reset index
        sendDataIndex = 0
        
        // send it
        sendData()
        */
    }
 
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic)
    {
        print("Central unsubbed from char.")
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager)
    {
        
        /*
        // Get data
        print(toSend[toSendIndex])
        dataToSend = toSend[toSendIndex]
            //.data(using: String.Encoding.utf8)
        sendDataIndex = 0
 
        sendData()
         */
    }
    
    var sendingEOM = false
    
    
    func sendData(input: Double = -1)
    {
        if (input != -1) {
            dataToSend = input
        }
        if sendingEOM {
            // send it
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
            
            // It didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
            return
        }
        
        // If we're not at the end of the message, we're still sending data
        
        /*
        // Are there any more data to send? If index is bigger, go into the body of this
        guard sendDataIndex! < toSend.count else {
            // we're done, no more stuff
            return
        }
        */
        
        var didSend = true
        
        while didSend {
            // make the next chunk of data to be sent
            /*
            // figure out how big the chunk is
            var amountToSend = dataToSend!.count - sendDataIndex!
            
            // Check if it's too long
            if (amountToSend > NOTIFY_MTU) {
                amountToSend = NOTIFY_MTU
            }
            */
            let amountToSend = 8
            
            
            // Copy the chunk we want
            let chunk = Data(from: dataToSend)
                
            /*
                dataToSend!.withUnsafeBytes{(body: UnsafePointer<UInt8>) in
                return Data(
                    bytes: body + sendDataIndex!,
                    count: amountToSend
                )
            }
            */
            
            
            
            
            print("printing chunk")
            print(chunk)
            // send it
            didSend = peripheralManager!.updateValue(chunk,
                        for: transferCharacteristic!, onSubscribedCentrals: nil)
            
            // Check if it actually sent
            if (!didSend) {
                return
            }
            
            let doubleOut = chunk.to(type: Double.self)
            print("Sent: \(doubleOut)")
            toSendIndex += 1
            
            /*
            // It sent! Update index
            sendDataIndex += amountToSend
            */
            /*
            // Was it the last one?
            if (sendDataIndex! >= dataToSend!.count) {
                
                // It was, so send a EOM
                
                // Set this so if it fails we'll send it next time
                
                // Send it
                let eomSent = peripheralManager!.updateValue(
                    "EOM".data(using: String.Encoding.utf8)!,
                    for: transferCharacteristic!,
                    onSubscribedCentrals: nil
                )
                
                if (eomSent) {
                    // It sent, we're all done
                    sendingEOM = false
                    print("Sent: EOM")
                }
                
                return
            }
            */
        }
    }
    
    // MARK: - Get Accelerometer Data
    func getMotionManagerUpdates() {
        
        // operation main queue
        //let accelQueue: OperationQueue = OperationQueue.main
        let gyroQueue: OperationQueue = OperationQueue.main
        
        // init interval for update (NSTimeInterval)
        self.motionManager.deviceMotionUpdateInterval = 1/60
        
        // get current gyro data
        if (self.motionManager.isDeviceMotionAvailable) {
            
            let gyroHandler: CMDeviceMotionHandler = { (gyroData:CMDeviceMotion?, error:Error?) -> Void in
                // errors
                if (error != nil) {
                    print("error: \(String(describing: error?.localizedDescription))")
                }else{
                    // success
                    if ((gyroData) != nil) {
                        
                        
                        // get gyroscopes values
                        let gyroX:String = String(format: "%.2f", (gyroData?.rotationRate.x)!) as String
                        let gyroY:String = String(format: "%.2f", (gyroData?.rotationRate.y)!) as String
                        let gyroZ:String = String(format: "%.2f", (gyroData?.rotationRate.z)!) as String
                        
                        print("gyro x: \(gyroX)")
                        print("gyro y: \(gyroY)")
                        print("gyro z: \(gyroZ)")
                        
                        // get accelerations values
                        let x:String = String(format: "%.2f", (gyroData?.userAcceleration.x)!) as String
                        let y:String = String(format: "%.2f", (gyroData?.userAcceleration.y)!) as String
                        let z:String = String(format: "%.2f", (gyroData?.userAcceleration.z)!) as String
                        
                        print("accel x: \(x)")
                        print("accel y: \(y)")
                        print("accel z: \(z)")
                        
                        // get gyroscopes values
                        let pitch = gyroData?.attitude.pitch
                        let yaw = gyroData?.attitude.yaw
                        let roll = gyroData?.attitude.roll
                        
                        print("pitch: \(pitch)")
                        self.sendData(input: pitch!)
                        print("yaw: \(yaw)")
                        self.sendData(input: yaw!)
                        print("roll: \(roll)")
                        self.sendData(input: roll!)
                    }
                }
            }
            self.motionManager.startDeviceMotionUpdates(to: gyroQueue, withHandler: gyroHandler)
        } else {
            print("not available")
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
 
