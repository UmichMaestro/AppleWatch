//
//  Buffer.swift
//  maestro-phone
//
//  Created by Prakash Kumar on 11/23/18.
//  Copyright © 2018 Maestro. All rights reserved.
//

import Foundation

import Foundation

class Buffer{
    //here is our buffer. It will be very similar to a queue.... but a little different in that it has 2 stages.
    
    var buffer_full:Bool = false
    let max_size:Int = 4
    var items:[Float] = []
    
    //each item in the queue will be a float. returns false if buffer is full
    func addItem(item:Float) -> Bool{
        if(items.count < 4){
            items.append(item)
            buffer_full = items.count == 4
            return true
        }
        return false;
    }
    
    func clear(){
        items = [Float]()
        buffer_full = false
    }
    
}
