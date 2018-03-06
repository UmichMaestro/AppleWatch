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
    var dataToSend: Double? //used in sendData()
    var sendDataIndex = Int(0) //testing var.
    var toSendIndex = Int(0) //testing var.
    var toSend: [Double] = [0, 0, 0, 0, 0, 0, 0, 0, 0] //testing var.
    
    //end of message
    var sendingEOM = false

    //called when app is open on the screen
    override func viewDidLoad()
    {
        super.viewDidLoad()
        toSendIndex = 0
        
        //starts the collection of motion data
        getMotionManagerUpdates()
        
        //init BT manager object
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        //if the app is not on the screen, don't advertise data over BT
        peripheralManager?.stopAdvertising()
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
 
    //function runs when central device unsubscribes from our characteristic
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic)
    {
        print("Central unsubbed from char.")
    }
    
    //currently unused, but if a packet fails to send, this function will get called
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
 
    //does the actually work of sending the data over BT
    func sendData(input: Double = -1)
    {
        //if user provided an input, sent dataToSend equal to that input
        if (input != -1) {
            dataToSend = input
        }
        
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
            
            //create a data object using the input
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
            //send our data chunk
            didSend = peripheralManager!.updateValue(chunk,
                        for: transferCharacteristic!, onSubscribedCentrals: nil)
            
            // Check if it actually sent
            if (!didSend) {
                return
            }
            
            //turn our data chunk back into a double so we can print it out
            //a testing check
            let doubleOut = chunk.to(type: Double.self)
            print("Sent: \(doubleOut)")
            
            //currently unused
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
    
    func getMotionManagerUpdates() {
        
        // operation main queue
        //let accelQueue: OperationQueue = OperationQueue.main
        let motionQueue: OperationQueue = OperationQueue.main
        
        // init interval for update (NSTimeInterval)
        self.motionManager.deviceMotionUpdateInterval = 1/60
        
        // get current gyro data
        if (self.motionManager.isDeviceMotionAvailable) {
            
            let motionHandler: CMDeviceMotionHandler = { (motionData:CMDeviceMotion?, error:Error?) -> Void in
                // errors
                if (error != nil) {
                    print("error: \(String(describing: error?.localizedDescription))")
                }else{
                    // success
                    if ((motionData) != nil) {
                        
                        // get gyroscopes values
                        let gyroX = motionData?.rotationRate.x
                        let gyroY = motionData?.rotationRate.y
                        let gyroZ = motionData?.rotationRate.z
                        
                        //send gyro values
                        self.sendData(input: gyroX!)
                        self.sendData(input: gyroY!)
                        self.sendData(input: gyroZ!)

                        // get accelerations values
                        let accelX = motionData?.userAcceleration.x
                        let accelY = motionData?.userAcceleration.y
                        let accelZ = motionData?.userAcceleration.z
                        
                        //send acceleration values
                        self.sendData(input: accelX!)
                        self.sendData(input: accelY!)
                        self.sendData(input: accelZ!)
                    
                        // get gyroscopes values
                        let pitch = motionData?.attitude.pitch
                        let yaw = motionData?.attitude.yaw
                        let roll = motionData?.attitude.roll
                        
                        print("pitch: \(pitch)")
                        self.sendData(input: pitch!)
                        print("yaw: \(yaw)")
                        self.sendData(input: yaw!)
                        print("roll: \(roll)")
                        self.sendData(input: roll!)
                    }
                }
            }
            self.motionManager.startDeviceMotionUpdates(to: motionQueue, withHandler: motionHandler)
        } else {
            print("not available")
        }
        
    }
    
    //"Stop Data Collection" button -- stops data collection and data from sending
    @IBAction func stop(_ sender: UIButton)
    {
        motionManager.stopDeviceMotionUpdates()
        peripheralManager?.stopAdvertising()
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
 
