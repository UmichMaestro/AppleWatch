//
//  ViewLevel4Selected.swift
//  maestro-phone
//
//  Created by Prakash Kumar on 11/24/18.
//  Copyright © 2018 Maestro. All rights reserved.
//

import Foundation
import UIKit

class ViewLevel4Selected:UIViewController{
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(state != .level_four){
            changeViewController(state: state)
        }
        
    }
    
    @IBAction func RecalibrateButtonPressed(_ sender: Any) {
        state = .largest_gesture
        changeViewController(state:state)
    }
    func changeViewController(state:AppState){
        print("called")
        let controller = storyboard?.instantiateViewController(withIdentifier: state_lookup[state.rawValue]!) as! UIViewController
        present(controller, animated: true, completion: nil)
    }
    
    
    @IBAction func b1Pressed(_ sender: Any) {
        level_state_prim = 41 * 2
        state = .start
        changeViewController(state: state)
    }
    
    
    @IBAction func b2Pressed(_ sender: Any) {
        level_state_prim = 42 * 2
        state = .start
        changeViewController(state: state)
    }
    
    @IBAction func b3Pressed(_ sender: Any) {
        level_state_prim = 43 * 2
        state = .start
        changeViewController(state: state)
    }
    
    @IBAction func b4Pressed(_ sender: Any) {
        level_state_prim = 44 * 2
        state = .start
        changeViewController(state: state)
    }
}
