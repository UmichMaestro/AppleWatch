//
//  ViewController.swift
//  maestro
//
//  Created by Christopher Baur on 1/28/18.
//  Copyright © 2018 Maestro_MDP.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var pairedStatus: UILabel!
    
    @IBOutlet weak var pairingButton: UIButton!
    var paired = false
    
    @IBAction func beginPairing(_ sender: Any) {
        if paired {
            pairedStatus.text = "Unpaired"
            pairingButton.backgroundColor = UIColor.blue
            pairingButton.setTitle("Begin Pairing", for: .normal)
            paired = false
        } else {
            pairedStatus.text = "Paired"
            pairingButton.backgroundColor = UIColor.red
            pairingButton.setTitle("End Pairing", for: .normal)
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

