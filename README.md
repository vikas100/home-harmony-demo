# Home Harmony Demo
This is a fully functional demo illustrating augmented reality in both still and video mode (CBCombinedPainter) and also featuring the ability to gather colors from a photo (CBColorFinder). 

#### CBCombinedPainter
CBCombinedPainter allows for both live video augmented reality and still based modifications of a photo. Its recommended operation is to first start the user in live mode CBCombinedPainter.startAugmentedReality, and then capture into still mode (CBCombinedPainter.captureToImagePainter). This allows for a seamless transition between both modes and a minimal user interface. CBCombinedPainter is a subclass of the CBImagePainter class, so it offers all of the still based methods and properties, while also allowing for moving back and forth between augmented reality and still painting (startAugmentedReality, stopAugmentedReality). CBImagePainter and as a consequence, CBCombinedPainter, its descendent, offers an ability to operate on gallery photos.


###### Moving between augmented reality and still mode, without capture
The following methods switch between still and video augmented reality. showAugmentedReality switches away from still mode and starts video based augmented reality. The showImagePainter method does the opposite.
```
- (void) showAugmentedReality;
- (void) showImagePainter;
```

###### Capture, transition between AR and still mode with captured image and paint
Calling captureToImagePainter stops augmented reality and loads the still painter with the captured image, entering still mode.
```
- (void) captureToImagePainter:(void (^)(void))block;
```

###### Pause and resume augmented reality
To pause and resume augmented reality, use the following methods. Typically this is desired while the view is partially obstructed, such as during the presentation of a menu, although this is not required.
```
- (void) startAugmentedReality;
- (void) stopAugmentedReality;
```

#### CBImagePainter (superclass of CBCombinedPainter)
As the superclass of CBCombinedPainter, CBImagePainter offers the still controls allowing finer control and detailed painting of a still image. Although it is recommended to use the CBCombinedPainter object, some users may want to separate the usage of still based painter or not use augmented reality at all. 


###### Image methods
The following properties provide access to a UIImage object, useful for saving to camera roll or social media, and a stillImage, which has additional methods and properties for more fine control and drawing if necessary.
```
@property (readonly, nonatomic) UIImage *previewImage;
@property (readonly, nonatomic) CBImagePainterImage *stillImage;
```

###### Adding multiple paint colors and selecting each one
Often users want multiple paint colors. This is accomplished through the method appendNewLayer to create. The current layer being painted or erased can be changed by setting the editLayerIndex and then using tools as normal. There is a limit to the number of layers that can be added, defined by maxLayerCount, while the total number of layers currently in the image is defined by layerCount.
```
- (BOOL) appendNewLayer;
@property (readonly, nonatomic) BOOL canAppendNewLayer;

- (BOOL) removeLayerAtIndex:(int)index;
@property (readonly, nonatomic) CBLayer *editLayer;
@property (assign, nonatomic) int editLayerIndex;
@property (readonly, nonatomic) int layerCount;
@property (readonly, nonatomic) int maxLayerCount;
```

###### Setting paint color
```
@property (retain, nonatomic) UIColor *paintColor;
- (void) setPaintColor:(UIColor *)uiColor updateImage:(BOOL)updateImage;
```

###### Global appearance
```
@property (assign, nonatomic) LightingType simulatedLighting;
```

###### Tools
```
@property (assign, nonatomic) ToolMode toolMode;
```

```
@property (assign, nonatomic) BOOL autoZoomEnabled;
@property (assign, nonatomic) BOOL autoBrushSizeEnabled;
@property (assign, nonatomic) BOOL brushTapFillEnabled;
@property (assign, nonatomic) BOOL smartBrushEnabled;
@property (assign, nonatomic) int brushSize;
@property (assign, nonatomic) BOOL touchPaintEnabled;

@property (assign, nonatomic) BOOL rectSnapToEnabled;
- (void) commitChanges;
- (void) decommitChanges;
```

###### Undo history, stepping backwards
```
@property (assign, nonatomic) int maxHistorySize;
@property (readonly, nonatomic) BOOL canStepBackward;
@property (assign, nonatomic) BOOL hasMadeChanges;
@property (readonly, nonatomic) BOOL hasChangesToCommit;
- (void) stepBackward;
- (void) clearHistory;
```

###### Zooming
```
@property (assign, nonatomic) BOOL canZoom;
@property (readonly, nonatomic) CGFloat zoomScale;
- (void) zoomOut;
```


###### Callbacks
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
- (void) setStillImage:(CBImagePainterImage *)stillImage; //required for CBVideoPainter
- (void) loadImage:(UIImage *)largeImage hasAlphaMasking:(BOOL)hasAlphaMasking;
- (UIImage *) getRenderedImage;
```

```
@property (readonly, nonatomic) NSString *projectID;
- (BOOL) loadProject:(NSString *)projectID fromDirectory:(NSString *)directoryPath;
- (NSString *) saveProjectToDirectory:(NSString *)directoryPath saveState:(BOOL)saveState;
+ (NSString *) cloneProject:(NSString *)path projectID:(NSString *)projectID;
```

###### Additional methods
Force a redraw of the image:
```
- (void) redraw;
```

To clear all paint colors and all changes to masks:
```
- (void) clearAll;
```


#### CBColorFinder
CBColorFinder is a component with two basic methods. First it allows for a color to be pulled from an image averaged at a point and then it also can return N of the most common colors seen in an image. Additionally, a CBColoring class provides useful methods for finding how close a color is to another, and color theory features useul to users. When combined together an interface to help users pull colors from their photos is available. 

```
@property (nonatomic, copy) void(^colorTouchedAtPoint)(TouchStep touchType, CGPoint point, UIColor *color);
```

```
- (NSArray *) getMostCommonColors:(int)count type:(CBColorType)type;
```

#### CBColoring

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
