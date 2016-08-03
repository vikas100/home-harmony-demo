//
//  CBConstructs.h
//  Cambrian
//
//  Created by Joel Teply on 12/1/11.
//  Copyright (c) 2011 Digital Rising LLC. All rights reserved.
//

#ifndef Cambrian_CBConstructs_h
#define Cambrian_CBConstructs_h

typedef struct _CBSample
{
    CGRect frame;
    
    double[3]  hsvMean;
    double[3]  hsvDeviation;
    BOOL[3]  hsvApplied;
    
    double[3]  labMean;
    double[3]  labDeviation;
    BOOL[3]  labApplied;
}
CBSample;

#endif
