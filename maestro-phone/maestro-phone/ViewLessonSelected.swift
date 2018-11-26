//
//  ViewLessonSelected.swift
//  maestro-phone
//
//  Created by Prakash Kumar on 11/24/18.
//  Copyright © 2018 Maestro. All rights reserved.
//

import Foundation
import UIKit

class ViewLessonSelected:UIViewController{
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         print(state)
        if(state != .lesson_selected){
            changeViewController(state: state)
        }
        
    }
    
    @IBAction func singlesoundsPressed(_ sender: Any) {
        state = .level_one
        changeViewController(state: state)
    }
    @IBAction func sustainPressed(_ sender: Any) {
        state = .level_two
        changeViewController(state: state)
    }
    @IBAction func dynamicsPressed(_ sender: Any) {
        state = .level_three
        changeViewController(state: state)
    }
    @IBAction func advancedPressed(_ sender: Any) {
        state = .level_four
        changeViewController(state: state)
    }
    func changeViewController(state:AppState){
        print("called")
        let controller = storyboard?.instantiateViewController(withIdentifier: state_lookup[state.rawValue]!) as! UIViewController
        present(controller, animated: true, completion: nil)
    }
}
