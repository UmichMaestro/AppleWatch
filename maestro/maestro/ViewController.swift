//
//  ViewController.swift
//  maestro
//
//  Created by Christopher Baur on 1/28/18.
//  Copyright © 2018 Maestro_MDP.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var paired_status: UILabel!
    
    @IBOutlet weak var pairing_button: UIButton!
    var paired = false
    
    @IBAction func beginPairing(_ sender: Any) {
        if paired {
            paired_status.text = "Unpaired"
            pairing_button.backgroundColor = UIColor.blue
            pairing_button.setTitle("Begin Pairing", for: .normal)
            paired = false
        } else {
            paired_status.text = "Paired"
            pairing_button.backgroundColor = UIColor.red
            pairing_button.setTitle("End Pairing", for: .normal)
            paired = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

