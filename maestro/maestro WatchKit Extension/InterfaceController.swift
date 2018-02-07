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
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        print("gets to awake")
        
        // update interface
        self.xValues.setText("intial")
        self.yValues.setText("intial")
        self.zValues.setText("intial")
        self.xValueGyro.setText("intial")
        self.yValueGyro.setText("intial")
        self.zValueGyro.setText("intial")
        
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
        let mainQueue: OperationQueue = OperationQueue.main
        
        // init interval for update (NSTimeInterval)
        self.motionManager.accelerometerUpdateInterval = 0.1
        self.motionManager.gyroUpdateInterval = 0.1
        
        // get current accelerometerData
        if (self.motionManager.isAccelerometerAvailable) {
            
            // define handler
            let accelHandler: CMAccelerometerHandler = { (accelerometerData:CMAccelerometerData?, error:Error?) -> Void in
                // errors
                if (error != nil) {
                    print("error: \(String(describing: error?.localizedDescription))")
                }else{
                    // success
                    if ((accelerometerData) != nil) {
                        
                        // get accelerations values
                        let x:String = String(format: "%.2f", (accelerometerData?.acceleration.x)!) as String
                        let y:String = String(format: "%.2f", (accelerometerData?.acceleration.y)!) as String
                        let z:String = String(format: "%.2f", (accelerometerData?.acceleration.z)!) as String
                        
                        print("x: \(x)")
                        print("y: \(y)")
                        print("z: \(z)")
                        
                        // set text labels
                        self.xValues.setText(x)
                        self.yValues.setText(y)
                        self.zValues.setText(z)
                    }
                }
            }
            
            // start accelerometer updates
            self.motionManager.startAccelerometerUpdates(to: mainQueue, withHandler: accelHandler)
        }
        
        // get current gyro data
        if (self.motionManager.isGyroAvailable) {
            
            self.xValueGyro.setText("in available")
            self.yValueGyro.setText("in available")
            self.zValueGyro.setText("in available")
            
            let gyroHandler: CMGyroHandler = { (gyroData:CMGyroData?, error:Error?) -> Void in
                // errors
                if (error != nil) {
                    print("error: \(String(describing: error?.localizedDescription))")
                }else{
                    // success
                    if ((gyroData) != nil) {
                        
                        // get gyroscopes values
                        let x:String = String(format: "%.2f", (gyroData?.rotationRate.x)!) as String
                        let y:String = String(format: "%.2f", (gyroData?.rotationRate.y)!) as String
                        let z:String = String(format: "%.2f", (gyroData?.rotationRate.z)!) as String
                        
                        print("x: \(x)")
                        print("y: \(y)")
                        print("z: \(z)")
                        
                        // set text labels
                        self.xValueGyro.setText(x)
                        self.yValueGyro.setText(y)
                        self.zValueGyro.setText(z)
                    }
                }
            }
            self.motionManager.startGyroUpdates(to: mainQueue, withHandler: gyroHandler)
        }
    }

}
