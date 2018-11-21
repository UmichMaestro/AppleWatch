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
    
    var state:AppState = .bluetooth
    var buffer:Buffer = Buffer()

    
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
    
    //function runs when a central device subscribes to our characteristic
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characterstic: CBCharacteristic)
    {
        print("central subbed to the char.")
        //getMotionManagerUpdates()
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
        
        /*
        while didSend
        {
        */
        if !thisPacketSent
        {
            
            
            // make the next chunk of data to be sent
            
            //create a data object using the input
            /*var chunkZero = Data(from: toSend[0]) // this is accelX
            let chunkOne = Data(from: toSend[1]) // this is accelY
            let chunkTwo = Data(from: toSend[2]) // this is 2nd accelX
            let chunkThree = Data(from: self.buffer.items[3]) // this is 2nd accelY*/
            
            
            var chunkZero = Data(from: self.buffer.items[0]) // this is accelX
            let chunkOne = Data(from: self.buffer.items[1]) // this is accelY
            let chunkTwo = Data(from: self.buffer.items[2]) // this is 2nd accelX
            let chunkThree = Data(from: self.buffer.items[3]) // this is 2nd accelY
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
            self.buffer.clear()
            
            
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
                        self.buffer.addItem(item: (Float(self.state.rawValue)))
                        
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
    
    //"Stop Data Collection" button -- stops data collection and data from sending
    /*@IBAction func stopDataCollection(_ sender: UIButton) {
        motionManager.stopDeviceMotionUpdates()
        //peripheralManager?.stopAdvertising()
    }
    @IBAction func startDataCollection(_ sender: Any) {
        self.getMotionManagerUpdates()
    }*/
    
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
        handleState();
    }
    
    

    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var device: UIImageView!
    @IBOutlet weak var device_modifier: UIImageView!
    @IBOutlet weak var textString: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    
    //this is a total hack... I'm sorry to whoever is reading this if I had time to learn iOS development better I would have done something better than this!!! :(
    func handleState(){
        switch(state){
        case .bluetooth:
            device_modifier.isHidden = false
            device.isHidden=true
            device_modifier.image = UIImage(named: "bluetooth")
            textString.text = "Please turn on the Bluetooth..."
            yesButton.isHidden = true
            noButton.isHidden = true
        case .largest_gesture_obtained:
            startButton.isHidden = true
            device.isHidden = true
            device_modifier.isHidden = true
            textString.isHidden = true
            nextButton.isHidden = true
            yesButton.isHidden = false
            noButton.isHidden = false
        case .hello:
            device.isHidden = true
            device_modifier.isHidden = true
            textString.isHidden = true
            nextButton.isHidden = false
            yesButton.isHidden = true
            noButton.isHidden = true
        case .largest_gesture:
            startButton.isHidden = false
            device.isHidden = true
            device_modifier.isHidden = true
            textString.isHidden = true
            nextButton.isHidden = true
            yesButton.isHidden = true
            noButton.isHidden = true
        case .phone_wrist:
            let a = 0
        case .start_cond:
            startButton.isHidden = false
            device.isHidden = true
            device_modifier.isHidden = true
            textString.isHidden = true
            nextButton.isHidden = true
            yesButton.isHidden = true
            noButton.isHidden = true
        case .cond_toggle:
            startButton.isHidden = false
            device.isHidden = true
            device_modifier.isHidden = true
            textString.isHidden = true
            nextButton.isHidden = true
            yesButton.isHidden = true
            noButton.isHidden = true
        default:
            let a = 0
        }
    }
    
    @IBAction func yesButtonPressed(_ sender: Any) {
        changeState(newState: .cond_toggle);
    }
    
    @IBAction func noButtonPressed(_ sender: Any) {
        changeState(newState: .largest_gesture);
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        changeState(newState: AppState(rawValue: state.rawValue + 1)!)
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        motionManager.stopDeviceMotionUpdates()
        usleep(100)
        self.getMotionManagerUpdates()
        
        if(state == .largest_gesture){
            changeState(newState: .largest_gesture_obtained)
        }
        
        //how this works: we will continually change between start_cond and cond_toggle when start is pressed. IF we notice a change from one to the other on the desktop app.... we need to be "looking" for the gesture w/ the alg manager
        if(state == .start_cond){
            changeState(newState: .cond_toggle)
        }
        else if(state == .cond_toggle){
            changeState(newState: .start_cond)
        }
        
        print(state)
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

