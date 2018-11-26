//
//  ViewPhoneWrist.swift
//  maestro-phone
//
//  Created by Prakash Kumar on 11/23/18.
//  Copyright © 2018 Maestro. All rights reserved.
//

import Foundation

import UIKit

class ViewPhoneWrist:UIViewController{
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         print(state)
        if(state != .phone_wrist){
            changeViewController(state: state)
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        state = .largest_gesture
        changeViewController(state: state)
    }
    
    func changeViewController(state:AppState){
        print("called")
        let controller = storyboard?.instantiateViewController(withIdentifier: state_lookup[state.rawValue]!) as! UIViewController
        present(controller, animated: true, completion: nil)
    }
}
