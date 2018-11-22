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
    
    enum Articulations:Double {
        case leg=0.3, std=0.6, sta=1
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
    var maxAccelYSlope:Float
    var maxAccelYLargest:Float
    var maxAccelYSampNum:Float
    var minAccelYLargest:Float
    var minAccelYSampNum:Float
    var currentAccelYRange:Float
    var currentAccelYSlope:Float
    var currentPitchRange:Float
    var sampleNum:Float
    var maxAccelYTime:Float
    var minAccelYTime:Float
    var currentMaxAccelYTime:Float
    var currentMinAccelYTime:Float
    
    //articulation detection
    let std_range: Float = 0.26;
    let leg_range: Float = 0.20;
    let sta_range: Float = 0.43;
    let std_r_up: Float = 0.24;
    let std_r_low: Float = 0.12;
    let leg_r_up: Float = 0.04;
    let sta_r_low: Float = 0.11;
    let std_slope: Float = 0.22;
    let leg_slope: Float = 0.15;
    let sta_slope: Float = 0.48;
    let std_s_up: Float = 0.35;
    let std_s_low: Float = 0.12;
    let leg_s_up: Float = 0.04;
    let sta_s_low: Float = 0.17;
    
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
        maxAccelYSlope = 0
        maxAccelYLargest = 0
        maxAccelYSampNum = 0
        minAccelYLargest = 0
        minAccelYSampNum = 0
        currentAccelYRange = 0
        currentAccelYSlope = 0
        currentMaxAccelYTime = 0
        currentMinAccelYTime = 0
        
        
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
            
            if(accelY > maxAccelYLargest){
                maxAccelYLargest = accelY
                maxAccelYTime = sampleNum
            }
            if(accelY < minAccelYLargest){
                minAccelYLargest = accelY
                minAccelYTime = sampleNum
            }

            
            
            maxPitchRange = maxPitchLargest - minPitchLargest
            maxAccelYRange = maxAccelYLargest - minAccelYLargest
            maxAccelYSlope = abs(maxAccelYRange / (maxAccelYTime - minAccelYTime))
            cutoffState = cutoffDetection(currentState: cutoffState, pitch:pitch, yaw:yaw)
            let dynamic:Dynamics = handleDynamic(current_range:maxPitchRange)
            let articulation:Articulations = handleArticulation(current_range:maxAccelYRange, current_slope:maxAccelYSlope)
            if(cutoffState == .cutoff){
                //we want to update the progState.
                progState = .endedLargest
                print(dynamic)
                print(articulation)
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
            
            if(accelY > maxAccelYLargest){
                maxAccelYLargest = accelY
                maxAccelYTime = sampleNum
            }
            if(accelY < minAccelYLargest){
                minAccelYLargest = accelY
                minAccelYTime = sampleNum
            }

            currentPitchRange = maxPitchLargest - minPitchLargest
            currentAccelYRange = maxAccelYLargest - minAccelYLargest
            currentAccelYSlope = abs(currentAccelYRange / (maxAccelYTime - minAccelYTime))
            cutoffState = cutoffDetection(currentState: cutoffState, pitch:pitch, yaw:yaw)
            let dynamic:Dynamics = handleDynamic(current_range:currentPitchRange)
            let articulation:Articulations = handleArticulation(current_range:currentAccelYRange, current_slope:currentAccelYSlope)
            print(dynamic)
            print(articulation)
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
    
    func handleArticulation(current_range:Float, current_slope:Float) -> Articulations {
        let ratioRange: Float = current_range / maxAccelYRange;
        let ratioSlope: Float = current_slope / maxAccelYSlope;
        
        let diff_std_range: Float = abs(std_range - ratioRange);
        let diff_leg_range: Float = abs(leg_range - ratioRange);
        let diff_sta_range: Float = abs(sta_range - ratioRange);
        
        let diff_std_slope: Float = abs(std_slope - ratioSlope);
        let diff_leg_slope: Float = abs(leg_slope - ratioSlope);
        let diff_sta_slope: Float = abs(sta_slope - ratioSlope);
        
        var standard = [Double](repeating: 0.0, count: 4);
        var legato = [Double](repeating: 0.0, count: 4);
        var staccato = [Double](repeating: 0.0, count: 4);
        
        if (ratioRange <= (std_range + std_r_up) && ratioRange >= (std_range - std_r_low)){
            standard[1] = 2;
        }
        if (ratioRange <= (leg_range + leg_r_up) && ratioRange >= 0){
            legato[1] = 1;
        }
        if (ratioRange <= 1 && ratioRange >= (sta_range - sta_r_low)){
            staccato[1] = 2;
        }
        
        if (ratioSlope <= (std_slope + std_s_up) && ratioSlope >= (std_slope - std_s_low)){
            standard[2] = 2;
        }
        if (ratioSlope <= (leg_slope + leg_s_up) && ratioSlope >= 0){
            legato[2] = 1;
        }
        if (ratioSlope <= 1 && ratioSlope >= (sta_slope - sta_s_low)){
            staccato[2] = 2;
        }
        
        if (diff_std_range < diff_std_range && diff_std_range < diff_sta_range){
            standard[3] = 1;
        }else if (diff_leg_range < diff_std_range && diff_leg_range < diff_sta_range){
            legato[3] = 1;
        }else if (diff_sta_range < diff_std_range && diff_sta_range < diff_leg_range){
            staccato[3] = 1;
        }
        
        if (diff_std_slope < diff_std_slope && diff_std_slope < diff_sta_slope){
            standard[4] = 1;
        }else if (diff_leg_slope < diff_std_slope && diff_leg_slope < diff_sta_slope){
            legato[4] = 1;
        }if (diff_sta_slope < diff_std_slope && diff_sta_slope < diff_leg_slope){
            staccato[4] = 5;
        }
        
        let std_sum: Float = standard.reduce(0,+);
        let leg_sum: Float = legato.reduce(0,+);
        let sta_sum: Float = staccato.reduce(0,+);
        
        if (std_sum > leg_sum && std_sum > sta_sum){
            return .std;
        }else if (leg_sum > std_sum && leg_sum > sta_sum){
            return .leg;
        }else if (sta_sum > std_sum && sta_sum > std_sum){
            return .sta;
        }else{
            if (std_sum == leg_sum){
                let decide = Bool.random();
                if (decide == false){
                    return .std;
                }else if (decide == true){
                    return .leg;
                }
            }else if (std_sum == sta_sum){
                let decide = Bool.random();
                if (decide == false){
                    return .std;
                }else if (decide == true){
                    return .sta;
                }
            }else if (leg_sum == sta_sum){
                let decide = Bool.random();
                if (decide == false){
                    return .leg;
                }else if (decide == true){
                    return .sta;
                }
            }else if (std_sum == leg_sum && std_sum == sta_sum){
                return .std;
            }
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
            if(change_count >= downbeat_threshold){
                nextState = .cutoff
                //TODO: push state
                stopGesture();
            }
            
            sampleNum = sampleNum + 1;
            
        }else if (currentState == .cutoff){
            nextState = .cutoff
        }
        prevPitch = pitch //update the prev pitch for next update call.
        prevYaw = yaw
        
        return nextState
    }
}
