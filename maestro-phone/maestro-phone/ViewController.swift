//
//  ViewController.swift
//  bluetooth_watch_test
//
//  Maestro 2018
//

import UIKit
import CoreBluetooth
import CoreMotion

class ViewController: UIViewController, CBPeripheralManagerDelegate {
    
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
    
    
    //end of message
    var sendingEOM = false
    
    //called when app is open on the screen
    override func viewDidLoad()
    {
        super.viewDidLoad()
        toSendIndex = 0
        
        //init BT manager object
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        //if the app is not on the screen, don't advertise data over BT
        peripheralManager?.stopAdvertising()
        motionManager.stopDeviceMotionUpdates()
    }
    
    //we don't know what this does
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager)
    {
        print("state: \(peripheral.state)")
        //if the peripheral isn't on, we can't transfer data over BT
        if(peripheral.state != .poweredOn)
        {
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
    }
    
    //function runs when a central device subscribes to our characteristic
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characterstic: CBCharacteristic)
    {
        print("central subbed to the char.")
        getMotionManagerUpdates()
    }
    
    //function runs when central device unsubscribes from our characteristic
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic)
    {
        print("Central unsubbed from char.")
        motionManager.stopDeviceMotionUpdates()
    }
    
    //currently unused, but if a packet fails to send, this function will get called
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager)
    {
        //sendData()
        sendLatency()
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
            
            // It didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
            //^^currently does not happen
            return
        }
        
        // If we're not at the end of the message, we're still sending data
        
        
        /*
         As we're always sending the same 4 things, and only sending when the
         array is filled, we don't need to check if our index is out of range
         as we don't use an index
         
         // Are there any more data to send? If index is bigger, go into the body of this
         guard self.toSendIndex < self.toSend.count else {
         // we're done, no more stuff, get more motion data
         print("yikes, we're doing something wrong, ended up in the guard")
         self.readyForUpdate = true
         return
         }
         */
        
        var didSend = true
        
        //while didSend {
        if thisPacketSent == false
        {
            
            
            // make the next chunk of data to be sent
            
            //create a data object using the input
            var chunkZero = Data(from: toSend[0]) // this is accelX
            let chunkOne = Data(from: toSend[1]) // this is accelY
            let chunkTwo = Data(from: toSend[2]) // this is second accelX
            let chunkThree = Data(from: toSend[3]) // this is the second accelY
            chunkZero.append(chunkOne)
            chunkZero.append(chunkTwo)
            chunkZero.append(chunkThree)
            
            
            // keeping for posterity, possible use in the future, possible edit
            // data to adjust count
            /*
             dataToSend!.withUnsafeBytes{(body: UnsafePointer<UInt8>) in
             return Data(
             bytes: body + sendDataIndex!,
             count: amountToSend
             )
             }
             */
            
            //print("printing chunk")
            //print(chunk)
            //send our data chunk
            didSend = peripheralManager!.updateValue(chunkZero,
                                                     for: transferCharacteristic!, onSubscribedCentrals: nil)
            
            // Check if it actually sent
            if (!didSend) {
                //print("We had a problem sending")
                return
            }
            
            //print(toSendIndex)
            toSendIndex += 1
            numberSent += 1
            //print("number sent: \(numberSent)")
            
            //turn our data chunk back into a double so we can print it out
            //a testing check
            
            // testing
            // first need to split it into two chunks
            //let doubleOut = chunk.prefix(upTo: 8).to(type: Double.self)
            //print("Tried to send: \(toSend[3])")
            //print("Sent: \(doubleOut)")
            
            //let secondOut = chunk.dropFirst(8).to(type: Double.self)
            //print("Tried to send: \(toSend[4])")
            //print("Also sent: \(secondOut)")
            
            self.readyForUpdate = true
            self.haveFirst = false
            self.thisPacketSent = true
            
            
            toSend[0] = 1000.0
            toSend[1] = 1000.0
            toSend[2] = 1000.0
            toSend[3] = 1000.0

            
            // Was it the last one?
            /*if (toSendIndex >= toSend.count) {
             // we need to get new motion values
             self.readyForUpdate = true
             self.haveFirst = false
             return
             }*/
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
                        
                        /*
                         // get gyroscopes values
                         let pitch = motionData?.attitude.pitch
                         let yaw = motionData?.attitude.yaw
                         let roll = motionData?.attitude.roll
                         
                         self.toSend[0] = pitch!
                         self.toSend[1] = yaw!
                         self.toSend[2] = roll!
                         */
                        
                        // get accelerations values
                        let accelX = motionData?.userAcceleration.x
                        let accelY = motionData?.userAcceleration.y
                        // let accelZ = motionData?.userAcceleration.z
                        
                        // set haveSecond to true for single sized test
                        if self.haveFirst {
                            self.toSend[2] = Float(accelX!)
                            self.toSend[3] = Float(accelY!)
                            
                        } else {
                            self.toSend[0] = Float(accelX!)
                            self.toSend[1] = Float(accelY!)
                            self.haveFirst = true
                        }
                        
                        
                        
                        /*
                         // get gyroscopes values
                         let gyroX = motionData?.rotationRate.x
                         let gyroY = motionData?.rotationRate.y
                         let gyroZ = motionData?.rotationRate.z
                         
                         //send gyro values
                         self.toSend[6] = gyroX!
                         self.toSend[7] = gyroY!
                         self.toSend[8] = gyroZ!
                         */
                        
                        /*
                        if haveSecond {// we have one dataset, we don't need another until we
                            // send it
                            self.readyForUpdate = false
                            self.haveFirst = false
                            self.toSendIndex = 0
                            self.thisPacketSent = false
                            self.sendData()
                        }
                        */
                        self.sendLatency()
                    }
                }
            }
            self.motionManager.startDeviceMotionUpdates(to: motionQueue, withHandler: motionHandler)
        } else {
            print("not available")
        }
        
    }
    
    //"Stop Data Collection" button -- stops data collection and data from sending
    @IBAction func stopDataCollection(_ sender: UIButton) {
        motionManager.stopDeviceMotionUpdates()
        //peripheralManager?.stopAdvertising()
    }
    @IBAction func startDataCollection(_ sender: Any) {
        self.getMotionManagerUpdates()
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
    
    
}

//nifty functions to turn doubles into data objects and back
extension Data {
    
    init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
    
    func to<T>(type:T.Type) -> T {
        return self.withUnsafeBytes{ $0.pointee}
    }
}

