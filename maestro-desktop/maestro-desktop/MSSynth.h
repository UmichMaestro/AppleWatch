//
//  instrument.hpp
//  RtAudio
//
//  Created by Jungho Bang on 11/11/17.
//


#import <Foundation/Foundation.h>


@interface MSSynth : NSObject

@property (nonatomic) void* obj_mem;

-(int)addfromcpp;
-(id)init: (int) num1 secondNumber:(int) num2;
-(void)dealloc;
-(int)getafromcpp;
-(int)getbfromcpp;

@end



