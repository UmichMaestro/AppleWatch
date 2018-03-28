//
//  ViewController.swift
//  maestro
//
//  Created by Christopher Baur on 1/28/18.
//  Copyright © 2018 Maestro_MDP.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    @IBOutlet var accelX: UILabel!
    @IBOutlet var accelY: UILabel!
    @IBOutlet var accelZ: UILabel!
    
    @IBOutlet var gyroX: UILabel!
    @IBOutlet var gyroY: UILabel!
    @IBOutlet var gyroZ: UILabel!
    
    @IBOutlet var pitch: UILabel!
    @IBOutlet var yaw: UILabel!
    @IBOutlet var roll: UILabel!
    
    let motionManager = CMMotionManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.getMotionManagerUpdates()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                        
                        // set text labels
                        self.gyroX.text = (gyroX)
                        self.gyroY.text = (gyroY)
                        self.gyroZ.text = (gyroZ)
                        
                        // get accelerations values
                        let x:String = String(format: "%.2f", (gyroData?.userAcceleration.x)!) as String
                        let y:String = String(format: "%.2f", (gyroData?.userAcceleration.y)!) as String
                        let z:String = String(format: "%.2f", (gyroData?.userAcceleration.z)!) as String
                        
                        print("accel x: \(x)")
                        print("accel y: \(y)")
                        print("accel z: \(z)")
                        
                        // set text labels
                        self.accelX.text = (x)
                        self.accelY.text = (y)
                        self.accelZ.text = (z)
                        
                        
                        
                        // get gyroscopes values
                        let pitch:String = String(format: "%.2f", (gyroData?.attitude.pitch)!) as String
                        let yaw:String = String(format: "%.2f", (gyroData?.attitude.yaw
                            )!) as String
                        let roll:String = String(format: "%.2f", (gyroData?.attitude.roll)!) as String
                        
                        print("pitch: \(pitch)")
                        print("yaw y: \(yaw)")
                        print("roll: \(roll)")
                        
                        // set text labels
                        self.pitch.text = (pitch)
                        self.yaw.text = (yaw)
                        self.roll.text = (roll)
                        
                    }
                }
            }
            self.motionManager.startDeviceMotionUpdates(to: gyroQueue, withHandler: gyroHandler)
        } else {
            self.gyroX.text = ("this is")
            self.gyroY.text = ("not")
            self.gyroZ.text = ("available")
        }
        
    }


}

