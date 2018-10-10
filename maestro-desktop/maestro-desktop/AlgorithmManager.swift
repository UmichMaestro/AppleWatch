//
//  AlgorithmManager.swift
//  maestro-desktop
//
//  Created by Prakash Kumar on 10/5/18.
//  Copyright © 2018 Christopher Baur. All rights reserved.
//

import Foundation
import Darwin



class AlgorithmManager{
    
    //data types
    enum Dynamics {
        case p, mp, mf, f, ff
    }
    
    enum State{
        case hold
        case prep
        case down_beat
        case action_point
        case sustain
        case loop
        case boop
        case cutoff
    }
    
    enum AlgorithmState{
        case startedLargest
        case endedLargest
        case begun
        case end
    }
    
    
    var progState:AlgorithmState
    
    //dynamic detection
    var maxPitchRange:Float
    var maxPitchLargest:Float
    var minPitchLargest:Float
    var maxYawRange:Float
    var maxYawLargest:Float
    var minYawLargest:Float
    var currentPitchRange:Float
    
    //cutoff detection
    var prevPitch:Float
    var prevYaw:Float
    var change_count:Int
    var cutoffState:State
    
    //constant algorithms
    let slope_p:Float = 0.0005
    let slope_y:Float = 0.000125
    
    let change_threshold:Int = 10
    let downbeat_threshold:Int = 5
    
    init(){
        progState = .startedLargest
        
        maxPitchRange = 0
        maxPitchLargest = 0
        minPitchLargest = 0
        maxYawRange = 0
        maxYawLargest = 0
        minYawLargest = 0
        currentPitchRange = 0
        
        
        prevPitch = 0
        prevYaw = 0
        change_count = 0
        cutoffState = .hold
    }
    
    func stopLargestGesture(){progState = .endedLargest}
    func startGesture(){
        if(progState == .endedLargest || progState == .end){
            progState = .begun
            cutoffState = .hold
            maxPitchLargest = 0
            maxYawLargest = 0
            minPitchLargest = 0
            minYawLargest = 0
        }
    }
    func stopGesture(){progState = .end} //TODO: see if this is what we want.
    
    func update(pitch:Float, yaw:Float){
        
        //print("current state: ")
        //print(progState)
        if(progState == .startedLargest){
            //we want to determine the largest PITCH range we can discern.
            if(pitch > maxPitchLargest){
                maxPitchLargest = pitch
            }
            if(pitch < minPitchLargest){
                minPitchLargest = pitch
            }
            maxPitchRange = maxPitchLargest - minPitchLargest
            cutoffState = cutoffDetection(currentState: cutoffState, pitch:pitch, yaw:yaw)
            let dynamic:Dynamics = handleDynamic(current_range:maxPitchRange)
            if(cutoffState == .cutoff){
                //we want to update the progState.
                progState = .endedLargest
                print(dynamic)
            }
        }else if(progState == .endedLargest){
            //so on so forth...
            //do nothing. the button will update this state on it's own.
        }else if (progState == .begun){
            //we want to determine the largest PITCH range we can discern.
            if(pitch > maxPitchLargest){
                maxPitchLargest = pitch
            }
            if(pitch < minPitchLargest){
                minPitchLargest = pitch
            }
            currentPitchRange = maxPitchLargest - minPitchLargest
            cutoffState = cutoffDetection(currentState: cutoffState, pitch:pitch, yaw:yaw)
            let dynamic:Dynamics = handleDynamic(current_range:currentPitchRange)
            print(dynamic)
        }
    }
    
    func handleDynamic(current_range: Float) -> Dynamics {
        //takes in a value for the value for l
        let ratio: Float = current_range / maxPitchRange;
        if(ratio > 0 && ratio < 0.48){
            return .p;
        }else if (ratio >= 0.48 && ratio < 0.7){
            return .mp;
        }else if (ratio >= 0.7 && ratio < 0.90){
            return .mf;
        }else if (ratio >= 0.9 && ratio < 0.97){
            return .f;
        }else{
            return .ff;
        }
    }
    
    private func cutoffDetection(currentState:State, pitch:Float, yaw:Float) -> State{
        print("current state: ")
        print(currentState)
        //state machine for determining action point.
        let pitch_change = pitch - prevPitch
        let yaw_change = yaw - prevYaw
        
        var nextState:State = currentState
        
        var cutoff_type:String = ""
        
        if(currentState == .hold){
            if(pitch_change > slope_p){
                change_count = change_count + 1
            }else{
                change_count = 0
            }
            
            if(change_count >= change_threshold){
                nextState = .prep
                change_count = 0
                //TODO: push state
            }
            
        }else if (currentState == .prep){
            if(pitch_change < -slope_p){
                change_count = change_count + 1
            }else{
                change_count = 0
            }
            
            if(change_count >= change_threshold){
                nextState = .down_beat
                //TODO: push state
                change_count = 0
            }
        }else if (currentState == .down_beat){
            if(pitch_change > slope_p){
                change_count = change_count + 1
            }else{
                change_count = 0
            }
            
            if(change_count >= downbeat_threshold){
                nextState = .action_point
                //TODO: push state
                change_count = 0
            }
            
        }else if (currentState == .action_point){
            if(yaw_change < -slope_y){
                change_count = change_count + 1
            }else {
                change_count = 0
            }
            
            if(change_count >= change_threshold){
                nextState = .sustain
                //TODO: push state
                change_count = 0
            }
        }else if (currentState == .sustain){
                if(pitch_change < -slope_p){
                    change_count = change_count + 1
                }else{
                    change_count = 0
                }
                
                if(change_count >= change_threshold){
                    if(yaw_change > slope_y){
                        cutoff_type = "loop"
                    }else if (yaw_change < -slope_y){
                        cutoff_type = "boop"
                    }
                    
                    change_count = 0
                }
                
                if(cutoff_type == "loop"){
                    if (yaw_change < -slope_y){
                        change_count = change_count + 1
                    }
                }else if (cutoff_type == "boop"){
                    change_count = change_count + 1
                }
                
                //if(change_count >= change_threshold){
                if(change_count >= 7){
                    nextState = .cutoff
                    //TODO: push state
                    stopGesture();
                }
        }else if (currentState == .cutoff){
            nextState = .cutoff
        }
        prevPitch = pitch //update the prev pitch for next update call.
        prevYaw = yaw
        
        return nextState
    }
}

/*
class AlgorithmManager{
    
    var arrSize:Int
    var samples:[Double]
    
    var started:Bool
    var startedLargest:Bool
    
    //set absolute thresholds for min and max pitches.
    private var minPitch:Double// = 0//DBL_MAX
    private var maxPitch:Double// = 0//DBL_MIN
    private var pitchRange:Double;
    
    private var maxPitchRange:Double
    
    private var prevPitch:Double = 0
    private var prevYaw:Double = 0
    
    //alg variables
    private var change_count:Int = 0
    
    
    //constant algorithms
    let slope_p:Double = 0.0005
    let slope_y:Double = 0.00025
    let change_threshold:Int = 5
    
    private enum State{
        case hold
        case prep
        case down_beat
        case action_point
        case sustain
        case loop
        case boop
        case cutoff
    }
    
    private var currentState:State;
    
    //largest gestures
    private var largestDynamic:Dynamics
    
    init(arrSize:Int) {
        self.arrSize = arrSize
        self.samples = Array(repeating: 0, count: arrSize)
        
        self.started = false
        self.startedLargest = false
        self.currentState = .hold
        
        self.minPitch = 0
        self.maxPitch = 0
        self.maxPitchRange = 0
        
        self.pitchRange = maxPitch - minPitch
        
        self.prevPitch = 0
        self.prevYaw = 0
        
        self.change_count = 0
        
        self.largestDynamic = .p
    }
    
    func startLargestGesture(){
        startedLargest = true
    }
    
    func stopLargestGesture(){
        startedLargest = false
        
        largestDynamic = handleDynamic(current_range: pitchRange)
    }
    
    func startGesture(){
        started = true
    }
    
    func stopGesture(){
        started = false
    }
    
    
    //meant to be called every single sample!
    func update(pitch:Double, yaw:Double /* we can add more here later....*/){
        if(started || startedLargest){
            if(pitch>maxPitch){
                maxPitch = pitch
            }
            if(pitch < minPitch){
                minPitch = pitch
            }
            
            pitchRange = maxPitch - minPitch
            
            //state machine for determining action point.
            let pitch_change = pitch - prevPitch
            let yaw_change = yaw - prevYaw
            
            var cutoff_detected:Bool = false
            
            var cutoff_type:String = ""
            
            if(currentState == .hold){
                if(pitch_change > slope_p){
                    change_count = change_count + 1
                }else{
                    change_count = 0
                }
                
                
                if(change_count >= change_threshold){
                    currentState = .prep
                    change_count = 0
                    //TODO: push state
                }
                
            }else if (currentState == .prep){
                if(pitch_change < -slope_p){
                    change_count = change_count + 1
                }else{
                    change_count = 0
                }
                
                if(change_count >= change_threshold){
                    currentState = .down_beat
                    //TODO: push state
                    change_count = 0
                }
            }else if (currentState == .down_beat){
                if(pitch_change > slope_p){
                    change_count = change_count + 1
                }else{
                    change_count = 0
                }
                
                if(change_count >= change_threshold){
                    currentState = .action_point
                    //TODO: push state
                    change_count = 0
                }
                
            }else if (currentState == .action_point){
                if(yaw_change < -slope_y){
                    change_count = change_count + 1
                }else {
                    change_count = 0
                }
                
                if(change_count >= change_threshold){
                    currentState = .sustain
                    //TODO: push state
                    change_count = 0
                }
            }else if (currentState == .sustain){
                if(!cutoff_detected){
                    if(pitch_change < -slope_p){
                        change_count = change_count + 1
                    }else{
                        change_count = 0
                    }
                    
                    if(change_count >= change_threshold){
                        if(yaw_change > slope_y){
                            cutoff_type = "loop"
                        }else if (yaw_change < -slope_y){
                            cutoff_type = "boop"
                        }
                        
                        change_count = 0
                    }
                    
                    if(cutoff_type == "loop"){
                        if (yaw_change < -slope_y){
                            change_count = change_count + 1
                        }
                    }else if (cutoff_type == "boop"){
                        change_count = change_count + 1
                    }
                    
                    if(change_count >= change_threshold){
                        currentState = .cutoff
                        //TODO: push state
                        cutoff_detected = true
                        stopGesture();
                    }
                    
                }
            }else if (currentState == .cutoff){
                if(startedLargest){
                    stopLargestGesture();
                }else{
                    stopGesture();
                }
            }
            
            
            
            prevPitch = pitch //update the prev pitch for next update call.
            prevYaw = yaw
        }
    }
    
    enum Dynamics {
        case p, mp, mf, f, ff
    }
    
    func handleDynamic(current_range: Double) -> Dynamics {
        //takes in a value for the value for l
        let ratio: Double = current_range / maxPitchRange;
        if(ratio > 0 && ratio < 0.48){
            return .p;
        }else if (ratio >= 0.48 && ratio < 0.7){
            return .mp;
        }else if (ratio >= 0.7 && ratio < 0.90){
            return .mf;
        }else if (ratio >= 0.9 && ratio < 0.97){
            return .f;
        }else{
            return .ff;
        }
    }
}
*/
