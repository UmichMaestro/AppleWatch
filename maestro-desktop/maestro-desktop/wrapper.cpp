//Ellie Epskamp-Hunt
//eepskamp@umich.edu


#include "RtAudio.h"
#include <iostream>
#include <thread>
#include <chrono>
#include <math.h>
#include "MSInstNode.h"
#include "MSEngine.h"
#include <fstream>
using namespace std;

//next steps: look at C# code to see how they used functions like this in old maestro
//may need to add more function parameters

//OBJ C approach https://www.ikiapps.com/experiences/2016/01/01/cpp-in-xcode-part-1
//C++/C approach http://www.swiftprogrammer.info/swift_vs_cpp.html

MSEngine s = MSEngine::sharedEngine();
int num_instruments;
extern "C" void setup()
{
    string paths[] = {
        "BbClar.ff.C4B4-5-330.msm",
        "BbClar.ff.C4B4-5-330.msm",
        "oboe.mf.C6Ab6-7-706.msm",
        "BbClar.ff.C4B4-5-330.msm",
        "oboe.ff.C4B4-10-439.msm",
    };
    num_instruments = sizeof(paths)/sizeof(string);
    
    for (int i=0; i<num_instruments; i++) {
        MSInstNode *inst = new MSInstNode(paths[i]);
        s.attachInstrument(inst);
    }
    
    cout << "-----------Set up complete------------";
}

extern "C" int startSound()
{
    
    for (int i=0; i<num_instruments; i++) {
        MSInstNode *inst = s.getInstruments()[i];
        inst->start(0.25);
        //if (i==0 || i==2) {
            //std::this_thread::sleep_for(std::chrono::milliseconds(500));
        //}
    }
    
    cout << "-----------Sound here------------";


    return 200;
}

//REQUIRES 0 < gain < 1 (i think??)
extern "C" void changeVolume(double gain)
{
    for (MSInstNode *i : s.getInstruments())
        i->setGain(gain);
    
}

extern "C" void cutoff()
{
    for (MSInstNode *i : s.getInstruments()) {
        i->release();
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }
    cout << "-----------Cutoff here------------";

    
}
