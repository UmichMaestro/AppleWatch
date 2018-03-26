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
    @IBOutlet var latency: WKInterfaceLabel!
    
    // not really sure what this does
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        return
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        let time_at_receive = CFAbsoluteTimeGetCurrent()
        let time_in = messageData.to(type: Double.self)
        
        let diff = time_at_receive - time_in
        latency.setText(String(diff))
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
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
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
