//
//  ViewStart.swift
//  maestro-phone
//
//  Created by Prakash Kumar on 11/24/18.
//  Copyright © 2018 Maestro. All rights reserved.
//

import Foundation
import UIKit

class ViewStart:UIViewController{
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(state != .start && state.rawValue <= 12){ //make sure state isn't actually sending start/end state
            changeViewController(state: state)
        }
        
        state = AppState(rawValue:level_state_prim)!
    }
    
    @IBAction func backPressed(_ sender: Any) {
        state = .lesson_selected
        changeViewController(state:state)
    }
    
    @IBAction func RecalibrateButtonPressed(_ sender: Any) {
        state = .largest_gesture
        changeViewController(state:state)
    }
    
    @IBAction func startPressed(_ sender: Any) {
        //let'sa go!
        bluetooth_manager.stop()
        usleep(100)
        bluetooth_manager.start()
        //change the state... but we don't need a viewcontroller for it!
        //state machine to send "starting" and "stopping" states...
        //every time the start button is pressed it is either level_state_prim
        //or it is level_state_prim+1... both identify the start of the gesture
        //corresponding with level_state_prim. Since it starts at 1.1(aka 11 * 2 = 22)
        //it works out.
        if(state.rawValue == level_state_prim){
            state = AppState(rawValue: (level_state_prim+1))!
        }else if (state.rawValue == level_state_prim+1){
            state = AppState(rawValue: level_state_prim)!
        }
    }
    
    func changeViewController(state:AppState){
        print("called")
        let controller = storyboard?.instantiateViewController(withIdentifier: state_lookup[state.rawValue]!) as! UIViewController
        present(controller, animated: true, completion: nil)
    }
}
