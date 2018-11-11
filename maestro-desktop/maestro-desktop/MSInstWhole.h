//
//  MSInstWhole.h
//  RtAudio
//
//  Created by Jake Baur on 11/3/18.
//

#ifndef MSInstWhole_h
#define MSInstWhole_h

#include <stdio.h>
#include <string>
#include "MSInstNode.h"

class MSInstWhole {
    std::vector<MSInstNode*> *instruments;
    int current_articulation;
    const int TOTAL_INSTRUMENTS = 3;
    
public:
    MSInstWhole(std::string paths[]);
    MSInstWhole();
    
    std::vector<MSInstNode*>& getInstruments();
    void setupInstNodes(std::string paths[]);
    void startSound(int articulation_type, double init_gain);
    void cutoff();
    void changeVolume(int articulation_type, double gain);
    void updateCurrentArticulation(int articulation_type);
};


#endif
