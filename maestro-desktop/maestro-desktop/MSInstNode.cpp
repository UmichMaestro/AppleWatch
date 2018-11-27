//
//  instrument.cpp
//  RtAudio
//
//  Created by Jungho Bang on 11/11/17.
//

#include "MSInstNode.h"
#include "MSEngine.h"
#include <cmath>

#include <fstream> 
#include <iostream>

#define DEFAULT_ENV_DURATION 40 // envelope duration (attack, release) for not segmented MSM

//string filename = "outputfile.txt";
//ofstream fout;



typedef struct {
    double frequency;
    uint32_t partials;
    uint32_t duration;
    uint32_t start; // attack - sustain
    uint32_t finish; // sustain - release
    uint64_t empty[5]; // for later use...
} Metadata; // memory structure

MSInstNode::MSInstNode(std::string path) {
    phase = 0;
    //fout.open(filename);
    
    FILE *file = fopen(path.c_str(),"rb");
    if (!file) {
        std::cout << "Unable to open file: " << path << std::endl;
    
        
        return;
    }
    
    // load MSM file
    Metadata meta;
    fread(&meta, sizeof(Metadata), 1, file);
    phaseIncr = M_PI * 2 / SAMPLE_RATE * meta.frequency; // trigonometrical function trick. after this, we don't need frequency.
    partials = meta.partials;
    duration = meta.duration;
    std:cout << "this is the duration " << duration << endl;
    if (meta.start == 0 || meta.finish == 0) { // error handling for using not-segmented MSM file. 
        std::cout << "Not segmented: " << path << std::endl;
        sustainStart = DEFAULT_ENV_DURATION;
        sustainFinish = duration-DEFAULT_ENV_DURATION;
    } else {
        sustainStart = meta.start;
        sustainFinish = meta.finish;
    }
    cells = meta.partials * meta.duration;
    //amplitudes = (double*)malloc(cells * sizeof(double));
    amplitudes = new double[cells];
    fread(amplitudes, sizeof(double), cells, file);
    fclose(file);
    
    time = -1;
}

double* MSInstNode::amplitudeForTime(int t) {
    if (t<duration)
        return &amplitudes[t*partials];
    else
        return NULL;
}

// interpolation between frame
double amplitudeInterpolate(double *amp0, double *amp1, int partial, int sample, bool mean) {
    double a0 = amp0[partial];
    double a1 = amp1[partial];
    
    if (mean)
        return (a0+a1)/2.0;
    else
        return a0 + (a1-a0)*sample/(double)SAMPLE_WINDOW; // amp interpolation
}

void MSInstNode::synthesize(float *buf, unsigned int nFrames) {
    
  
    if (time < 0) // not activated 
        return;
    
    double p = phase;
    double gain = currentGain;
    double gainIncr = (gain == targetGain) ? 0 : (targetGain-gain)/nFrames; // for ramping
    
    for (int t = 0; t < BUFFER_MSM_COUNT; t++) { // for each MSM frame
        bool mean;
        double *amp0, *amp1;
        
        if (time+t < sustainStart || time+t > sustainFinish) { // play the MSM data if in attack or release
            mean = false;
            amp0 = amplitudeForTime(time+t);
            amp1 = amplitudeForTime(time+t+1);

            if (amp0 == NULL || amp1 == NULL) {
                //std::cout << "Released instrument" << endl;
                time = -1; // we don't want to play this instrument anymore
                return;
            }
            //std::cout << *amp0 << "\n";
            //std::cout << *amp1 << "\n";
            time ++;
        } else { // simulate sustain
            mean = true;
            amp0 = amplitudeForTime(sustainStart);
            amp1 = amplitudeForTime(sustainFinish);
        }
        
        for (int s = 0; s < SAMPLE_WINDOW; s++) {
            double out = 0;
            for (int i=0; i<partials; i++) {
                double amp = amplitudeInterpolate(amp0, amp1, i, s, mean);
                //std::cout << amp << "\n";
                //fout << p << "\n";
        
                out += amp * gain * sin(p*(i+1)) / 1000; // TODO change phase back if you dont work
            }
            //fout << "\n";
            int outIndex = t*SAMPLE_WINDOW + s;
            //std::cout << out <<", " <<outIndex << "\n";
            buf[outIndex*2] += out; // since we have two channels: left, right
            buf[outIndex*2+1] += out;
            
            float factor = 0.5 * (1 - cos(2 * 3.1415626 * outIndex*2 / (nFrames*2-1)));
            
            
            p += phaseIncr; //TODO change c[hase backif you dont work
            gain += gainIncr; // ramping the gain change
        }
        
    }
    
    phase = p;
    currentGain = targetGain;
    return;
}

void MSInstNode::start(double initialGain) {
    //std::cout << "Start instrument" << endl;
    
    currentGain = initialGain;
    targetGain = initialGain;
    
    time = 0;
}

void MSInstNode::setGain(double gain) {
    targetGain = gain; // actual gain updating is handled in synthesize function with proper ramping
}

void MSInstNode::release() {
    //std::cout << "Releasing instrument..." << endl;
    
    time = this->sustainFinish;
}

MSInstNode::~MSInstNode(){
    delete[] amplitudes;
    //fout.close();

}
