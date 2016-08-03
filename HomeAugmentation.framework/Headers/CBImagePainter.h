//
//  CBImagePainter.h
//  Cambrian
//
//  Created by Joel Teply on 2/15/13.
//
//

#import <Foundation/Foundation.h>
#import <UIKIt/UIKit.h>

#import "CBImageTypes.h"
#import "CBImage.h"

@interface CBImagePainterImage : CBImage

@end

@interface CBImagePainter : UIView

@property (readonly, nonatomic) UIImage *previewImage;
@property (readonly, nonatomic) CBImagePainterImage *stillImage;
@property (readonly, nonatomic) CBLayer *editLayer;
@property (assign, nonatomic) int editLayerIndex;
@property (assign, nonatomic) BOOL autoZoomEnabled;

//Material choices
@property (retain, nonatomic) UIColor *paintColor;
@property (readonly, nonatomic) NSString *projectID;

//Global appearance
@property (assign, nonatomic) LightingType simulatedLighting;

@property (assign, nonatomic) BOOL autoBrushSizeEnabled;
@property (assign, nonatomic) BOOL brushTapFillEnabled;
@property (assign, nonatomic) BOOL smartBrushEnabled;
@property (assign, nonatomic) BOOL rectSnapToEnabled;

@property (assign, nonatomic) ToolMode toolMode;
@property (assign, nonatomic) int brushSize;
@property (assign, nonatomic) int maxHistorySize;
@property (assign, nonatomic) BOOL canZoom;
@property (readonly, nonatomic) CGFloat zoomScale;
@property (readonly, nonatomic) BOOL canStepBackward;
@property (assign, nonatomic) BOOL hasMadeChanges;
@property (readonly, nonatomic) BOOL hasChangesToCommit;

@property (readonly, nonatomic) int layerCount;
@property (readonly, nonatomic) int maxLayerCount;
@property (readonly, nonatomic) BOOL canAppendNewLayer;
@property (assign, nonatomic) BOOL touchPaintEnabled;
@property (assign, nonatomic) BOOL allowColorAdjustment;

@property (assign, nonatomic) float alphaIntensity;
@property (assign, nonatomic) float betaIntensity;

@property (nonatomic, copy) void(^busyLoadingBlock)(BOOL completed);

@property (nonatomic, copy) BOOL(^shouldStartToolBlock)(ToolMode tool);
@property (nonatomic, copy) void(^startedToolBlock)(ToolMode tool);
@property (nonatomic, copy) void(^finishedToolBlock)(ToolMode tool);

@property (nonatomic, copy) void(^historyChangedBlock)(void);

@property (nonatomic, copy) void(^scrolledContentsBlock)();
@property (nonatomic, copy) void(^zoomingStartedBlock)();
@property (nonatomic, copy) void(^zoomingCompletedBlock)();

- (void) loadImage:(UIImage *)largeImage hasAlphaMasking:(BOOL)hasAlphaMasking;

- (BOOL) loadProject:(NSString *)projectID fromDirectory:(NSString *)directoryPath;
- (NSString *) saveProjectToDirectory:(NSString *)directoryPath saveState:(BOOL)saveState;

+ (NSString *) cloneProject:(NSString *)path projectID:(NSString *)projectID;

- (void) setPaintColor:(UIColor *)uiColor updateImage:(BOOL)updateImage;

- (UIImage *) getRenderedImage;

- (void) stepBackward;
- (void) clearHistory;

- (void) commitChanges;
- (void) decommitChanges;

- (BOOL) appendNewLayer;
- (BOOL) removeLayerAtIndex:(int)index;
- (void) redraw;

- (void) showRectangle;

- (void) setStillImage:(CBImagePainterImage *)stillImage; //required for CBVideoPainter

- (void) cloneProject;
- (void) clearAll;

- (void) zoomOut;

@end