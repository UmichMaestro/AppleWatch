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
    enum Dynamics:Double {
        case p=0.2, mp=0.4, mf=0.6, f=0.8, ff=1
    }
    
//    enum Articulations:Double {
//        case
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
    var maxAccelYRange:Float
//    var maxAccelYSlope:Float
    var maxAccelYLargest:Float
//    var maxAccelYSampNum:Float
    var minAccelYLargest:Float
//    var minAccelYSampNum:Float
    var currentAccelYRange:Float
//    var currentAccelYSlope:Float
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
        maxAccelYRange = 0
//        maxAccelYSlope = 0
        maxAccelYLargest = 0
//        maxAccelYSampNum = 0
        minAccelYLargest = 0
//        minAccelYSampNum = 0
        currentAccelYRange = 0
//        currentAccelYSlope = 0
        
        
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
            maxAccelYLargest = 0
            minAccelYLargest = 0
        }
    }
    func stopGesture(){progState = .end} //TODO: see if this is what we want.
    
    func update(pitch:Float, yaw:Float, accelY:Float){
        
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
            
/*            if(accelY > maxAccelYLargest){
                maxAccelYLargest = accelY
            }
            if(accelY < minAccelYLargest){
                minAccelYLargest = accelY
            }
*/
            
            
            maxPitchRange = maxPitchLargest - minPitchLargest
//            maxAccelYRange = maxAccelYLargest - minAccelYLargest
//            maxAccelYSlope =
            cutoffState = cutoffDetection(currentState: cutoffState, pitch:pitch, yaw:yaw)
            let dynamic:Dynamics = handleDynamic(current_range:maxPitchRange)
//            let articulation:Articulations = handleArticulation(current_range:maxAccelYRange, current_slope:maxAccelYSlope)
            if(cutoffState == .cutoff){
                //we want to update the progState.
                progState = .endedLargest
                print(dynamic)
//                print(articulation)
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
            
/*            if(accelY > maxAccelYLargest){
                maxAccelYLargest = accelY
            }
            if(accelY < minAccelYLargest){
                minAccelYLargest = accelY
            }
*/
            currentPitchRange = maxPitchLargest - minPitchLargest
//            currentAccelYRange = maxAccelYLargest - minAccelYLargest
//            currentAccelYSlope =
            cutoffState = cutoffDetection(currentState: cutoffState, pitch:pitch, yaw:yaw)
            let dynamic:Dynamics = handleDynamic(current_range:currentPitchRange)
//            let articulation:Articulations = handleArticulation(current_range:currentAccelYRange, current_slope:currentAccelYSlope)
            print(dynamic)
//            print(articulation)
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
    
/*    func handleArticulation(current_range:Float, current_slope:Float) -> Articulations {
        
    }
*/
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
            if(change_count >= downbeat_threshold){
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
