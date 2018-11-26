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

MSEngine s;
//= MSEngine::sharedEngine();
int num_instruments;
extern "C" void setup()
{
    s = MSEngine::sharedEngine();
    string paths[][3] = {
        {"Bassoon.ff.C4B4-10-444.msm",
        "Bassoon.ff.C4B4-10-staccato.msm",
        "Bassoon.ff.C4B4-10-4-legato.msm"
        },
        {"BbClar.ff.C4B4-5.msm",
        "BbClar.ff.C4B4-5-staccato.msm",
        "BbClar.ff.C5B5-1-5-legato.msm"
        },
        {"flute.nonvib.ff.B3B4-11-442.msm",
        "flute.nonvib.ff.B3B4-11-442-staccato.msm",
        "flute.nonvib.ff.B3B4-11-4-legato.msm"
        },
        {"Horn.ff.C4B4-10-442.msm",
        "Horn.ff.C4B4-10-staccato.msm",
        "Horn.ff.C4B4-10-4-legato.msm"
        },
        {"oboe.ff.C4B4-10-439.msm",
        "oboe.ff.C4B4-10-staccato.msm",
        "oboe.ff.C4B4-10-4-legato.msm"
        }
    };
    
    
    num_instruments = sizeof(paths)/(sizeof(string) * 3);
    for (int i=0; i<num_instruments; i++) {
        //MSInstNode inst(paths[i]); //testing linkage
        s.attachInstrument(paths[i]);
    }
    
    cout << "-----------Set up complete------------";
}

//REQUIRES 0 < gain < 1 (i think??)
extern "C" void changeVolume(int articulationType, double gain)
{
    for (MSInstWhole *i : s.getInstruments())
        i->changeVolume(articulationType, gain);
    
}

extern "C" void cleanUp(){
    s.cleanUp();
}


extern "C" int startSound(int articulationType, double initGain = .25)
{
    for (int i=0; i<num_instruments; i++) {
        s.getInstruments()[i]->startSound(articulationType, initGain);
        /*if (i==0 || i==2) {
         std::this_thread::sleep_for(std::chrono::milliseconds(500));
        }*/
    }
    cout << "-----------Sound here------------";
    
    return 200;
}


extern "C" void cutoff()
{
    cout <<"cutoff called"<<endl;
    for (MSInstWhole *i : s.getInstruments()) {
        i->cutoff();
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }
    cout << "-----------Cutoff here------------";
    
    
}
