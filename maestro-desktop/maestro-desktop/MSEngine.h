//
//  MSEngine.hpp
//  RtAudio
//
//  Created by Jungho Bang on 11/11/17.
//

#ifndef MSEngine_h
#define MSEngine_h

#include <stdio.h>
#include "RtAudio.h"
#include "MSInstNode.h"
#include "MSInstWhole.h"
#include <cmath>
#define SAMPLE_RATE 44100.0
#define SAMPLE_WINDOW 441
#define BUFFER_MSM_COUNT 4 // how many msm amp data in each buffer

using namespace std;

class MSEngine {
public:
    static MSEngine& sharedEngine() { // singleton
        static MSEngine instance;
        return instance;
    }
    MSEngine();
    
private:
    RtAudio *audio;
    RtAudio::StreamParameters *outParam;
    vector<MSInstWhole*> *instruments;
    
    // static function should be implemented in the class definition
    static int staticCallback(void *outbuf, void *inbuf, unsigned int nFrames, double streamtime, RtAudioStreamStatus status, void *userdata) {
        
        memset(outbuf, 0, nFrames*2*sizeof(float));
        for (MSInstWhole *i : ((MSEngine*)userdata)->getInstruments())
            for (MSInstNode *j : i->getInstruments()) {
                j->synthesize((float*)outbuf, nFrames); // MSEngine is friend class of MSInstNode, so it can call synthesize()
            }

        /*for(int n = 0; n < nFrames / 2; n += 2)
        {
            float factor = 0.5 * (1 - cos(2 * 3.1415626 * n / (nFrames*2-1)));
            *((float*)outbuf + (n * sizeof(float))) = (*((float*)outbuf + (n * sizeof(float)))) * factor;
            *((float*)outbuf + ((n + 1) * sizeof(float))) = (*((float*)outbuf + ((n + 1) * sizeof(float)))) * factor;
            //cout << " heyyyy " << endl;
        }*/
        return 0;
    }
    
public:
    void attachInstrument(string paths[]);
    void clearInstruments();
    vector<MSInstWhole*>& getInstruments();
    void cleanUp();
    
};

#endif
