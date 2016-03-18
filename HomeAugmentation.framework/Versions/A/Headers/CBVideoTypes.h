//
//  CBVideoTypes.h
//  Cambrian
//
//  Created by Joel Teply on 1/16/12.
//  Copyright (c) 2012 Digital Rising LLC. All rights reserved.
//

#ifndef Cambrian_CBVideoTypes_h
#define Cambrian_CBVideoTypes_h

typedef enum
{
    LightingUnknown = 0,
    LightingNone,
	LightingPoor,
    LightingIndoorLow,
    LightingIndoorModerate,
    LightingIndoorHigh,
    LightingOutdoorLow,
    LightingOutdoorModerate,
    LightingOutdoorHigh
} Lighting;

typedef enum
{
    ThresholdModeInit = 0,
    ThresholdModeStaticHue,
    ThresholdModeStaticSat,
    ThresholdModeStaticVal,
    ThresholdModeStaticDist,
	
    ThresholdModeSetStaticThreshold,
    ThresholdModeComplete,
    
} ThresholdMode;

#endif
