//
//  InterfaceController.swift
//  maestro WatchKit Extension
//
//  Created by Christopher Baur on 1/28/18.
//  Copyright © 2018 Maestro_MDP.
//

import CoreMotion
import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    let motionManager = CMMotionManager()
    
    @IBOutlet var xValues: WKInterfaceLabel!
    @IBOutlet var yValues: WKInterfaceLabel!
    @IBOutlet var zValues: WKInterfaceLabel!
    
    @IBOutlet var xValueGyro: WKInterfaceLabel!
    @IBOutlet var yValueGyro: WKInterfaceLabel!
    @IBOutlet var zValueGyro: WKInterfaceLabel!
    @IBOutlet var attitudePitch: WKInterfaceLabel!
    @IBOutlet var attitudeYaw: WKInterfaceLabel!
    @IBOutlet var attitudeRoll: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        print("gets to awake")
        
        // update interface
        self.xValues.setText("intial")
        self.yValues.setText("intial")
        self.zValues.setText("intial")
        self.xValueGyro.setText("gyroIntial")
        self.yValueGyro.setText("gyroIntial")
        self.zValueGyro.setText("gyroInitial")
        
        print("gets to post-interface")
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        getMotionManagerUpdates()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    // MARK: - Get Accelerometer Data
    func getMotionManagerUpdates() {
        
        // operation main queue
        //let accelQueue: OperationQueue = OperationQueue.main
        let gyroQueue: OperationQueue = OperationQueue.main
        
        // init interval for update (NSTimeInterval)
        self.motionManager.deviceMotionUpdateInterval = 1
        
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
                        
                        // set text labels
                        self.xValueGyro.setText(gyroX)
                        self.yValueGyro.setText(gyroY)
                        self.zValueGyro.setText(gyroZ)
 
                        
                        
                        // get accelerations values
                        let x:String = String(format: "%.2f", (gyroData?.userAcceleration.x)!) as String
                        let y:String = String(format: "%.2f", (gyroData?.userAcceleration.y)!) as String
                        let z:String = String(format: "%.2f", (gyroData?.userAcceleration.z)!) as String
                        
                        print("accel x: \(x)")
                        print("accel y: \(y)")
                        print("accel z: \(z)")
                        
                        // set text labels
                        self.xValues.setText(x)
                        self.yValues.setText(y)
                        self.zValues.setText(z)
                        
                        
                        
                        // get gyroscopes values
                        let pitch:String = String(format: "%.2f", (gyroData?.attitude.pitch)!) as String
                        let yaw:String = String(format: "%.2f", (gyroData?.attitude.yaw
                            )!) as String
                        let roll:String = String(format: "%.2f", (gyroData?.attitude.roll)!) as String
                        
                        print("pitch: \(pitch)")
                        print("yaw y: \(yaw)")
                        print("roll: \(roll)")
                        
                        // set text labels
                        self.attitudePitch.setText(pitch)
                        self.attitudeYaw.setText(yaw)
                        self.attitudeRoll.setText(roll)
                        
                    }
                }
            }
            self.motionManager.startDeviceMotionUpdates(to: gyroQueue, withHandler: gyroHandler)
        } else {
            self.xValueGyro.setText("this is")
            self.yValueGyro.setText("not")
            self.zValueGyro.setText("available")
        }
        
    }

}
