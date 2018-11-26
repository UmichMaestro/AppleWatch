//
//  ViewLargestGesture.swift
//  maestro-phone
//
//  Created by Prakash Kumar on 11/23/18.
//  Copyright © 2018 Maestro. All rights reserved.
//

import Foundation
import UIKit

class ViewLargestGesture:UIViewController{

    @IBAction func startButtonPressed(_ sender: Any) {
        bluetooth_manager.stop()
        usleep(100)
        bluetooth_manager.start()
        state = .largest_gesture_obtained
        changeViewController(state: state)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         print(state)
        if(state != .largest_gesture){
            changeViewController(state: state)
        }
    }
    
    func changeViewController(state:AppState){
        print("called")
        let controller = storyboard?.instantiateViewController(withIdentifier: state_lookup[state.rawValue]!) as! UIViewController
        present(controller, animated: true, completion: nil)
    }
}
