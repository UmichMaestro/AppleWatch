//
//  ViewSplash.swift
//  maestro-phone
//
//  Created by Prakash Kumar on 11/21/18.
//  Copyright © 2018 Maestro. All rights reserved.
//

import Foundation

import UIKit

class ViewSplash: UIViewController{
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bluetooth_manager.load()
        bluetooth_manager.start()
        changeViewController(state: state)
    }
    
    func changeViewController(state:AppState){
        print("called")
        let controller = storyboard?.instantiateViewController(withIdentifier: state_lookup[state.rawValue]!) as! UIViewController
        present(controller, animated: true, completion: nil)
    }
    
}
