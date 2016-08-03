//
//  CBConstructs.h
//  Cambrian
//
//  Created by Joel Teply on 12/1/11.
//  Copyright (c) 2011 Cambrian Tech LLC. All rights reserved.
//

#ifndef Cambrian_CBImageTypes_h
#define Cambrian_CBImageTypes_h

typedef enum
{
    CBAccuracyLow,
    CBAccuracyMedium,
    CBAccuracyHigh,
}  CBAccuracy;

typedef enum
{
    CBFilterNone,
    CBFilterDarken,
    CBFilterMultiply,
    CBFilterColorBurn,
    CBFilterLinearBurn,
    CBFilterDarkerColor,
    CBFilterLighten,
    CBFilterScreen,
    CBFilterColorDodge,
    CBFilterLinearDodge,
    CBFilterAdd,
    CBFilterLighterColor,
    CBFilterOverlay,
    CBFilterSoftLight,
    CBFilterHardLight,
    CBFilterVividLight,
    CBFilterLinearLight,
    CBFilterPinLight,
    CBFilterHardMix,
    CBFilterDifference,
    CBFilterExclusion,
    CBFilterSubtract,
    CBFilterDivide,
    CBFilterHue,
    CBFilterSaturation,
    CBFilterColor,
    CBFilterLuminosity,
}  CBFilter;

typedef enum
{
    CBColorSpaceHSV,
    CBColorSpaceRGBA,
    CBColorSpaceBW,
    CBColorSpaceLab,
}  CBColorSpace;

typedef enum
{
    CBColorTypeAll,
    CBColorTypeShadows,
    CBColorTypeMidtones,
    CBColorTypeHighlights,
}  CBColorType;

typedef enum
{
    CBAnchorPointCenter,
    CBAnchorPointNorth,
    CBAnchorPointNortheast,
    CBAnchorPointEast,
    CBAnchorPointSoutheast,
    CBAnchorPointSouth,
    CBAnchorPointSouthwest,
    CBAnchorPointWest,
    CBAnchorPointNorthwest,
}  CBAnchorPoint;

typedef enum
{
    CBInterpolationNN,
    CBInterpolationBilinear,
    CBInterpolationBicubic,
    CBInterpolationNearest,
    CBInterpolationLanczos,
} CBInterpolation;

typedef enum
{
    CBSampleTypeRGB = 1 << 0,
    CBSampleTypeHSV = 1 << 1,
    CBSampleTypeAll = 0b111,
} CBSampleType;

typedef enum
{
    ToolModeFill = 0,
    ToolModePaintbrush = 1,
    ToolModeEraser = 2,
    ToolModeRectangle = 3,
}  ToolMode;

typedef enum
{
    ToolStateStarted,
    ToolStateMoved,
    ToolStateFinished,
}  ToolState;

typedef enum
{
    TouchStepBegan,
    TouchStepMoved,
    TouchStepEnded,
    TouchStepCancelled,
}  TouchStep;

typedef enum
{
    LightingTypeNone,
    LightingTypeIncandescent,
    LightingTypeFluorescent,
    LightingTypeLEDWhite,
    LightingTypeLEDWarm,
    LightingTypeDaylightMorning,
    LightingTypeDaylight,
    LightingTypeDaylightEvening,
    LightingTypeDaylightOvercast,
}  LightingType;

typedef enum
{
    SheenMatte,
    SheenEggshell,
    SheenSatin,
    SheenSemiGloss,
    SheenGloss,
    SheenHighGloss,
}  Sheen;

typedef enum
{
    TransparencyNone,
    TransparencyClear,
    TransparencyTranslucent,
    TransparencyTransparent,
    TransparencySemiTransparent,
    TransparencySolid,
    TransparencyUltraSolid,
}  Transparency;

typedef enum
{
    FinishNone,
    FinishAgedPatina,
    FinishAntiqueLeather,
    FinishBrightCanvas,
    FinishMatte,
    FinishChalkboard,
    FinishWhiteboard,
    FinishCrackle,
    FinishFrosted,
    FinishGlitter,
    FinishGlowInTheDark,
    FinishSand,
    FinishHammered,
    FinishDenim,
    FinishMetallic,
    FinishRiverRock,
    FinishSlipResistant,
    FinishSuede,
    FinishWetLook,
}  Finish;

typedef enum
{
    ImageOrientationUndefined = 0,
    ImageOrientationNormal = 1,
    ImageOrientation90 = 6,
    ImageOrientation180 = 3,
    ImageOrientation270 = 8,
} ImageOrientation;

typedef struct _CBMaskingParameters
{
    double hsvThresholds[4];
    bool applyHsvThresholds[4];
    
    bool applyEdges;
    bool showMasking;
}
CBMaskingParameters;

#endif
