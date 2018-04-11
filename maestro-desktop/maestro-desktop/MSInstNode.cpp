
#include "MSInstNode.hpp"

MSInstNode::MSInstNode(int x, int y)
{
    a = x;
    b = y;
}

int MSInstNode::add()
{
    return a + b;
}
int MSInstNode::getA()
{
    return a;
}
int MSInstNode::getB()
{
    return b; 
}
