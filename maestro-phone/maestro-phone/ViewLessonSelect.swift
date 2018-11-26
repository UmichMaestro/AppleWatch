//
//  ViewLessonSelect.swift
//  maestro-phone
//
//  Created by Prakash Kumar on 11/24/18.
//  Copyright © 2018 Maestro. All rights reserved.
//

import Foundation
import UIKit

class ViewLessonSelect:UIViewController{
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(state)
        if(state != .mode_select){
            changeViewController(state: state)
        }
        
    }
    
    func changeViewController(state:AppState){
        print("called")
        let controller = storyboard?.instantiateViewController(withIdentifier: state_lookup[state.rawValue]!) as! UIViewController
        present(controller, animated: true, completion: nil)
    }
    
    
    @IBAction func lessonButtonPressed(_ sender: Any) {
        state = .lesson_selected
        changeViewController(state: state)
        
    }
    
    @IBAction func freeplayButtonPressed(_ sender: Any) {
    }
    
}
