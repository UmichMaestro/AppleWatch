#import "MSSynth.h"
#include "MSInstNode.hpp"

@implementation MSSynth

-(id) init:(int) num1 secondNumber:(int) num2
{
    self = [super init];
    MSInstNode* obj = new MSInstNode(num1, num2);
    self.obj_mem = (void*) obj;
    return self;
}

-(void) dealloc
{
    MSInstNode* end = (MSInstNode*) self.obj_mem;
    delete end;
}
-(int) addfromcpp
{
    MSInstNode* use = (MSInstNode*) self.obj_mem;
    return use->add();
}

-(int) getafromcpp
{
    MSInstNode* use = (MSInstNode*) self.obj_mem;
    return use->getA();
}
-(int) getbfromcpp
{
    MSInstNode* use = (MSInstNode*) self.obj_mem;
    return use->getB();
}

@end
