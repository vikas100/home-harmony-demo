# Home Harmony Demo
This is a fully functional demo illustrating augmented reality in both still and video mode (CBCombinedPainter) and also featuring the ability to gather colors from a photo (CBColorFinder). 

## CBCombinedPainter
CBCombinedPainter allows for both live video augmented reality and still based modifications of a photo. Its recommended operation is to first start the user in live mode CBCombinedPainter.startAugmentedReality, and then capture into still mode (CBCombinedPainter.captureToImagePainter). This allows for a seamless transition between both modes and a minimal user interface. CBCombinedPainter is a subclass of the CBImagePainter class, so it offers all of the still based methods and properties, while also allowing for moving back and forth between augmented reality and still painting (startAugmentedReality, stopAugmentedReality). CBImagePainter and as a consequence, CBCombinedPainter, its descendent, offers an ability to operate on gallery photos.

```
@property (nonatomic, strong) NSString* runSFMTest;
@property (nonatomic, assign) CGPoint paintPoint;
@property (nonatomic, strong) UIColor *paintColor;
@property (nonatomic, strong) UIImage *texture;
@property (nonatomic, weak) GLKView *output;
@property (nonatomic, readonly) BOOL isRunning;

@property (nonatomic, strong) dispatch_queue_t cb_queue;

+ (CBVideoPainter *) getInstance;

void dispatch_cb(dispatch_block_t block);
void dispatch_cb_get_result(dispatch_block_t block);

- (BOOL) startRunning;
- (BOOL) stopRunning;

- (BOOL)captureCurrentState:(CBImagePainter*)imagePainter completed:(void (^)(void))block;
- (BOOL)captureCurrentState:(void (^)(CBImagePainterImage *))block;

- (void) clearAll;
```

### CBImagePainter
Although it is recommended to use the CBCombinedPainter object, some users may want to separate the usage of still based painter or not use augmented reality at all. 

```
@property (readonly, nonatomic) UIImage *previewImage;
@property (readonly, nonatomic) CBImagePainterImage *stillImage;
@property (readonly, nonatomic) CBLayer *editLayer;
@property (assign, nonatomic) int editLayerIndex;
@property (assign, nonatomic) BOOL autoZoomEnabled;
```

###### Material choices
```
@property (retain, nonatomic) UIColor *paintColor;
@property (readonly, nonatomic) NSString *projectID;
@property (nonatomic, strong) UIImage *texture;
```

###### Global appearance
```
@property (assign, nonatomic) LightingType simulatedLighting;
```

###### Tools
```
@property (assign, nonatomic) BOOL autoBrushSizeEnabled;
@property (assign, nonatomic) BOOL brushTapFillEnabled;
@property (assign, nonatomic) BOOL smartBrushEnabled;
@property (assign, nonatomic) BOOL rectSnapToEnabled;
@property (assign, nonatomic) ToolMode toolMode;
```

```
@property (assign, nonatomic) int brushSize;
@property (assign, nonatomic) int maxHistorySize;
@property (assign, nonatomic) BOOL canZoom;
@property (readonly, nonatomic) CGFloat zoomScale;
@property (readonly, nonatomic) BOOL canStepBackward;
@property (assign, nonatomic) BOOL hasMadeChanges;
@property (readonly, nonatomic) BOOL hasChangesToCommit;
```

```
@property (readonly, nonatomic) int layerCount;
@property (readonly, nonatomic) int maxLayerCount;
@property (readonly, nonatomic) BOOL canAppendNewLayer;
@property (assign, nonatomic) BOOL touchPaintEnabled;
@property (assign, nonatomic) BOOL allowColorAdjustment;
```

```
@property (assign, nonatomic) float alphaIntensity;
@property (assign, nonatomic) float betaIntensity;
```

```
@property (nonatomic, copy) void(^busyLoadingBlock)(BOOL completed);

@property (nonatomic, copy) BOOL(^shouldStartToolBlock)(ToolMode tool);
@property (nonatomic, copy) void(^startedToolBlock)(ToolMode tool);
@property (nonatomic, copy) void(^finishedToolBlock)(ToolMode tool);

@property (nonatomic, copy) void(^historyChangedBlock)(void);

@property (nonatomic, copy) void(^scrolledContentsBlock)();
@property (nonatomic, copy) void(^zoomingStartedBlock)();
@property (nonatomic, copy) void(^zoomingCompletedBlock)();
```

```
- (void) loadImage:(UIImage *)largeImage hasAlphaMasking:(BOOL)hasAlphaMasking;
```

```
- (BOOL) loadProject:(NSString *)projectID fromDirectory:(NSString *)directoryPath;
```

```
- (NSString *) saveProjectToDirectory:(NSString *)directoryPath saveState:(BOOL)saveState;
```

```
+ (NSString *) cloneProject:(NSString *)path projectID:(NSString *)projectID;
```

```
- (void) setPaintColor:(UIColor *)uiColor updateImage:(BOOL)updateImage;
```

```
- (UIImage *) getRenderedImage;
```

```
- (void) stepBackward;
- (void) clearHistory;
```

```
- (void) commitChanges;
- (void) decommitChanges;
```

```
- (BOOL) appendNewLayer;
- (BOOL) removeLayerAtIndex:(int)index;
- (void) redraw;
```

```
- (void) setStillImage:(CBImagePainterImage *)stillImage; //required for CBVideoPainter
```

```
- (void) cloneProject;
- (void) clearAll;
```

```
- (void) zoomOut;
```


## CBColorFinder
CBColorFinder is a component with two basic methods. First it allows for a color to be pulled from an image averaged at a point and then it also can return N of the most common colors seen in an image. Additionally, a CBColoring class provides useful methods for finding how close a color is to another, and color theory features useul to users. When combined together an interface to help users pull colors from their photos is available. 

```
@property (nonatomic, copy) void(^colorTouchedAtPoint)(TouchStep touchType, CGPoint point, UIColor *color);
```

```
- (NSArray *) getMostCommonColors:(int)count type:(CBColorType)type;
```

## CBColoring

```
+ (NSArray *)complementsForColor:(UIColor *)color count:(int)count angle:(double)angleSpan;
```

```
+ (NSArray *)adjacentColors:(UIColor *)color count:(int)count angle:(double)angleSpan;
```

```
+ (NSArray *)shadesOfColor:(UIColor *)color count:(int)count;
```

```
+ (double)distance:(UIColor *)colorA
         fromColor:(UIColor *)colorB;
```

```
+ (double)distance:(UIColor *)colorA
         fromColor:(UIColor *)colorB
             asHSV:(BOOL)asHSV
       coefficient:(CGFloat[3])coefficient;
```

```
+ (void) convertRGB:(UIColor *)rgbColor toHSV:(CGFloat[3])hsv;
```

```
+ (void) convertRGB:(UIColor *)rgbColor toHSL:(CGFloat[3])hsl;
```
