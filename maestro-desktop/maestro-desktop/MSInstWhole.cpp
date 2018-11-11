//
//  MSInstWhole.cpp
//  maestro-desktop
//
//  Created by Christopher Baur on 11/3/18.
//  Copyright © 2018 Christopher Baur. All rights reserved.
//

#include "MSInstWhole.h"
#include "MSInstNode.h"

#include <string>
#include <stdio.h>
#include <vector>
#include <iostream>

MSInstWhole::MSInstWhole(std::string paths[]) {
    instruments = new std::vector<MSInstNode*>();
    setupInstNodes(paths);
    current_articulation = -1;
};

MSInstWhole::MSInstWhole() {
    instruments = new std::vector<MSInstNode*>();
    current_articulation = -1;
};

std::vector<MSInstNode*>& MSInstWhole::getInstruments() {
    return *instruments;
};

void MSInstWhole::setupInstNodes(std::string paths[]) {
    for (int i = 0; i < TOTAL_INSTRUMENTS; i++) {
        MSInstNode *inst = new MSInstNode(paths[i]);
        instruments->push_back(inst);
    }
};

void MSInstWhole::startSound(int articulation_type, double init_gain) {
    updateCurrentArticulation(articulation_type);
    (*instruments)[articulation_type]->start(init_gain);
};

void MSInstWhole::cutoff() {
    (*instruments)[current_articulation]->release();
};

void MSInstWhole::changeVolume(int articulation_type, double gain) {
    updateCurrentArticulation(articulation_type);
    (*instruments)[current_articulation]->setGain(gain);
};

void MSInstWhole::updateCurrentArticulation(int articulation_type) {
    if (articulation_type != current_articulation) {
        if (current_articulation != -1) {
            (*instruments)[articulation_type]->release();
        }
        current_articulation = articulation_type;
    }
}
