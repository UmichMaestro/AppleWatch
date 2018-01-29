//
//  InterfaceController.swift
//  maestro WatchKit Extension
//
//  Created by Christopher Baur on 1/28/18.
//  Copyright © 2018 Maestro_MDP.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    @IBOutlet var pairingButton: WKInterfaceButton!
    
    @IBOutlet var pairingStatus: WKInterfaceLabel!
    
    var paired = false
    
    @IBAction func beginPairing() {
        if paired {
            pairingStatus.setText("Unpaired")
            pairingButton.setBackgroundColor(UIColor.blue)
            pairingButton.setTitle("Begin Pairing")
            paired = false
        } else {
            pairingStatus.setText("Paired")
            pairingButton.setBackgroundColor(UIColor.red)
            pairingButton.setTitle("End Pairing")
            paired = true
        }
    }
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
