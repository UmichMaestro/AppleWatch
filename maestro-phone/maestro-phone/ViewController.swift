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
    var toSend: [Float] = [0, 0, 0, 0] // holds motion data - two pairs of accleration along the x and z axes
    
    //variables to control the order of sample updates and transfers
    var readyForUpdate = true
    var haveFirst = false // used to determine which indexes to put the data in
    
    //called when app is open on the screen
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //create BT manager object
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
    }
    
    //function runs when central device unsubscribes from our characteristic
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic)
    {
        print("Central unsubbed from char.")
        motionManager.stopDeviceMotionUpdates()
    }
    
    //if a packet fails to send, this function will get called
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager)
    {
        sendData()
    }
    
    //does the actually work of sending the data over BT
    func sendData()
    {
        var didSend = true
    
        // make the next chunk of data to be sent
        //create a data object using the input
        var chunkZero = Data(from: toSend[0]) // this is accelX
        let chunkOne = Data(from: toSend[1]) // this is accelZ
        let chunkTwo = Data(from: toSend[2]) // this is 2nd accelX
        let chunkThree = Data(from: toSend[3]) // this is 2nd accelZ
        
        //make one whole data object starting with chunkZero
        chunkZero.append(chunkOne)
        chunkZero.append(chunkTwo)
        chunkZero.append(chunkThree)
        
        //send our data chunk
        didSend = peripheralManager!.updateValue(chunkZero,
                                                 for: transferCharacteristic!, onSubscribedCentrals: nil)
        
        // Check if it actually sent
        if (!didSend)
        {
            return
        }
        
        //set booleans back to correct values to get new motion data
        self.readyForUpdate = true
        self.haveFirst = false
        
        //set toSend values to bad values so that if there's a problem with the order of sending,
        //it's obvious
        toSend[0] = 1000.0
        toSend[1] = 1000.0
        toSend[2] = 1000.0
        toSend[3] = 1000.0
    }
    
    
    func getMotionManagerUpdates() {
        
        // operation main queue
        //let accelQueue: OperationQueue = OperationQueue.main
        let motionQueue: OperationQueue = OperationQueue.main
        
        // init interval for update (NSTimeInterval)
        self.motionManager.deviceMotionUpdateInterval = 1 / 100
        
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
                        let accelZ = motionData?.userAcceleration.z
                        // let accelY = motionData?.userAcceleration.y (not used in current implementation)
                
                        // set have Second to true for single sized test
                        if self.haveFirst {
                            self.toSend[2] = Float(accelX!)
                            self.toSend[3] = Float(accelZ!)
                            
                            //we have a whole dataset, don't overwrite it until it's been sent!
                            self.readyForUpdate = false
                            self.haveFirst = false
                            self.sendData()
                            
                        } else {
                            //save first data point
                            self.toSend[0] = Float(accelX!)
                            self.toSend[1] = Float(accelZ!)
                            self.haveFirst = true
                        }
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
    
    //testing function -- currently unused
    //calculates bluetooth latency
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

