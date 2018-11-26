//
//  ViewLevel3Selected.swift
//  maestro-phone
//
//  Created by Prakash Kumar on 11/24/18.
//  Copyright © 2018 Maestro. All rights reserved.
//

import Foundation
import UIKit

class ViewLevel3Selected:UIViewController{
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(state != .level_three){
            changeViewController(state: state)
        }
        
    }
    
    func changeViewController(state:AppState){
        print("called")
        let controller = storyboard?.instantiateViewController(withIdentifier: state_lookup[state.rawValue]!) as! UIViewController
        present(controller, animated: true, completion: nil)
    }

    
    @IBAction func b1Pressed(_ sender: Any) {
        level_state_prim = 31 * 2
        state = .start
        changeViewController(state: state)
    }
    
    @IBAction func b2Pressed(_ sender: Any) {
        level_state_prim = 32 * 2
        state = .start
        changeViewController(state: state)
    }
    
    @IBAction func b3Pressed(_ sender: Any) {
        level_state_prim = 33 * 2
        state = .start
        changeViewController(state: state)
    }
    
}
