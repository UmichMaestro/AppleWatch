//
//  ViewLevel1Selected.swift
//  maestro-phone
//
//  Created by Prakash Kumar on 11/24/18.
//  Copyright © 2018 Maestro. All rights reserved.
//

import Foundation
import UIKit

class ViewLevel1Selected:UIViewController{
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         print(state)
        if(state != .level_one){
            changeViewController(state: state)
        }
        
    }

    @IBAction func b1Pressed(_ sender: Any) {
        level_state_prim = 11 * 2
        state = .start
        changeViewController(state: state)
    }
    
    @IBAction func b2Pressed(_ sender: Any) {
        level_state_prim = 12 * 2
        state = .start
        changeViewController(state: state)
    }
    
    @IBAction func b3Pressed(_ sender: Any) {
        level_state_prim = 13 * 2
        state = .start
        changeViewController(state: state)
    }
    
    @IBAction func b4Pressed(_ sender: Any) {
        level_state_prim = 14 * 2
        state = .start
        changeViewController(state: state)
    }
    
    
    @IBAction func b5Pressed(_ sender: Any) {
        level_state_prim = 15 * 2
        state = .start
        changeViewController(state: state)
    }
    
    @IBAction func b6Pressed(_ sender: Any) {
        level_state_prim = 16 * 2
        state = .start
        changeViewController(state: state)
    }
    
    @IBAction func b7Pressed(_ sender: Any) {
        level_state_prim = 17 * 2
        state = .start
        changeViewController(state: state)
    }
    
    @IBAction func b8Pressed(_ sender: Any) {
        level_state_prim = 18 * 2
        state = .start
        changeViewController(state: state)
    }
    
    @IBAction func b9Pressed(_ sender: Any) {
        level_state_prim = 19 * 2
        state = .start
        changeViewController(state: state)
    }
    
    func changeViewController(state:AppState){
        print("called")
        let controller = storyboard?.instantiateViewController(withIdentifier: state_lookup[state.rawValue]!) as! UIViewController
        present(controller, animated: true, completion: nil)
    }
}
