//
//  ViewController.swift
//  watch_connectivity
//
//  Created by Christopher Baur on 3/26/18.
//  Copyright © 2018 Maestro. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {
    

    @IBOutlet var timeDelay: UILabel!
    
    @IBOutlet var number: UILabel!
    
    var number_in = Int(0)
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        let timeNow = CFAbsoluteTimeGetCurrent()
        let timeIn = messageData.to(type: Double.self)
        number_in += 1
        number.text = String(number_in)
        timeDelay.text = String(timeNow - timeIn)
    }
    
    // no idea what these are for
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        return
    }
    
    // no idea what these are for
    func sessionDidBecomeInactive(_ session: WCSession) {
        return
    }
    
    // no idea what these are for
    func sessionDidDeactivate(_ session: WCSession) {
        return
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func send_a_message() {
        let currentTime = CFAbsoluteTimeGetCurrent()
        
        if (WCSession.default.isReachable) {
            let message = Data(from: currentTime)
            WCSession.default.sendMessageData(message, replyHandler: nil, errorHandler: nil)
            
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

