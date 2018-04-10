//
//  InterfaceController.swift
//  watch_connectivity WatchKit Extension
//
//  Created by Christopher Baur on 3/26/18.
//  Copyright © 2018 Maestro. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet var timeStart: WKInterfaceLabel!
    @IBAction func startSending() {
        print("start pushed")
        sending_status = true
        var start_time = Date().timeIntervalSince1970
        while sending_status {
            if ((Date().timeIntervalSince1970 - start_time) > 0.05) {
                send_a_message()
                start_time = Date().timeIntervalSince1970
            }
        }
    }
    @IBAction func stopSending() {
        print("stop pushed")
        sending_status = false
    }
    
    var sending_status = false
    var start_time = Double(0)
    
    // not really sure what this does
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        return
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        return
    }
    

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        let session = WCSession.default
        session.delegate = self
        session.activate()
        start_time = CFAbsoluteTimeGetCurrent()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func send_a_message() {
        let currentTime = CFAbsoluteTimeGetCurrent()
        
        if (WCSession.default.isReachable) {
            let message = Data(from: currentTime)
            WCSession.default.sendMessageData(message, replyHandler: nil, errorHandler: nil)
            timeStart.setText(String(currentTime))
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
