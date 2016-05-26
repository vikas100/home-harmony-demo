# Home Harmony Demo
This is a fully functional demo illustrating augmented reality in both still and video mode (CBCombinedPainter) and also featuring the ability to gather colors from a photo (CBColorFinder). We have chosen an objective-c libary to allow for backwards compatibility, but we recommend development in swift and using a bridging header to load the framework. This method has been employed in the demo. Additionally, we offer a smaller and less full featured demo if desired that demonstrates the most basic functionality.

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

###### Load an image from a gallery
To load an image from the gallery or elsewhere, call the loadImage method and pass it a UIImage. If desired, the alpha layer can control areas that are off limits for painting, which is useful for pre-rendered images in the app. Additional information can be provided upon request on how to generate these images in a program like PhotoShop
```
- (void) loadImage:(UIImage *)largeImage hasAlphaMasking:(BOOL)hasAlphaMasking;
```

###### Image methods
The following properties provide access to a UIImage object, useful for a smaller preview, and a stillImage, which has additional methods and properties for more fine control and drawing if necessary.
```
@property (readonly, nonatomic) UIImage *previewImage;
@property (readonly, nonatomic) CBImagePainterImage *stillImage;
```
Importantly, a high quality, full resolution image may be obtained for saving to camera roll or sharing via social media by calling the following method:
```
- (UIImage *) getRenderedImage;
```
###### Setting paint color for the current layer (editLayerIndex)
```
@property (retain, nonatomic) UIColor *paintColor;
- (void) setPaintColor:(UIColor *)uiColor updateImage:(BOOL)updateImage;
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

###### Saved Project Features
Projects can be saved, copied (cloned), or loaded. The projects are saved to a directory and if necessary, the undo history can be saved as well by setting the saveState property of the saveProjectToDirectory method.
```
@property (readonly, nonatomic) NSString *projectID;
- (BOOL) loadProject:(NSString *)projectID fromDirectory:(NSString *)directoryPath;
- (NSString *) saveProjectToDirectory:(NSString *)directoryPath saveState:(BOOL)saveState;
+ (NSString *) cloneProject:(NSString *)path projectID:(NSString *)projectID;
```

###### Tools

*ToolMode Property*
The tool mode may be set and defaults to paintbrush, which is a dual purpose tool when brushTapFillEnabled is TRUE. In this mode of operation, tapping will auto fill an area, while drawing will act as a paintbrush. If desired, the tool mode may be set to TooModeFill, where only tap works and brushTapFillEnabled may be set to false so that the paintbrush does not fill on tap.
```
@property (assign, nonatomic) ToolMode toolMode;
typedef enum
{
    ToolModeFill = 0,
    ToolModePaintbrush = 1,
    ToolModeEraser = 2,
    ToolModeRectangle = 3,
}  ToolMode;
@property (assign, nonatomic) BOOL brushTapFillEnabled;
```

*Fine paintbrush and eraser control*
Additionally, the paintbrush operates in smart mode (smartBrushEnabled), which utilizes many different machine vision algorithms to find the nearest edge, allowing for a roughly painted area to paint cleanly up to a barrier such as a wall or an object, which is ideal for the touchscreen interface that does not offer the precision of a stylus. Another useful feature is that the brushSize defaults to auto-sizing itself, so that it will choose a size as the user draws that fits the free space. This is turned on by setting autoBrushSizeEnabled to TRUE, but if direct control is desired, this may be turned off and brushSize may be directly set to a desired radius.
```
@property (assign, nonatomic) BOOL smartBrushEnabled;
@property (assign, nonatomic) BOOL autoBrushSizeEnabled;
@property (assign, nonatomic) int brushSize;
```

*Rectangle controls*
When the tool mode is rectangle, the following methods are relevant. Commit changes allows for the rectangle to be applied and decommit, to ignore the changes and make it disappear. The property rectSnapToEnabled makes the rectangle magnetically snap to lines that were discovered in the image.
```
- (void) commitChanges;
- (void) decommitChanges;
@property (assign, nonatomic) BOOL rectSnapToEnabled;
```

###### Undo history, stepping backwards, clearing history
```
@property (assign, nonatomic) int maxHistorySize;
@property (readonly, nonatomic) BOOL canStepBackward;
@property (assign, nonatomic) BOOL hasMadeChanges;
@property (readonly, nonatomic) BOOL hasChangesToCommit;
- (void) stepBackward;
- (void) clearHistory;
```

###### Zooming on pinch, fully zooming out
```
@property (assign, nonatomic) BOOL canZoom;
@property (readonly, nonatomic) CGFloat zoomScale;
@property (assign, nonatomic) BOOL autoZoomEnabled;
- (void) zoomOut;
```

###### Callbacks on status changes

App is currently loading a project or image
```
@property (nonatomic, copy) void(^busyLoadingBlock)(BOOL completed);
```

App is starting a tool, such as brush starting to draw. Disable by returning false from shouldStartToolBlock.
```
@property (nonatomic, copy) BOOL(^shouldStartToolBlock)(ToolMode tool);
@property (nonatomic, copy) void(^startedToolBlock)(ToolMode tool);
@property (nonatomic, copy) void(^finishedToolBlock)(ToolMode tool);
```

Undo history is changing in size. Check for whether undo is possible by looking at the hasMadeChanges property
```
@property (nonatomic, copy) void(^historyChangedBlock)(void);
```

Methods for scrolling and zooming
```
@property (nonatomic, copy) void(^scrolledContentsBlock)();
@property (nonatomic, copy) void(^zoomingStartedBlock)();
@property (nonatomic, copy) void(^zoomingCompletedBlock)();
```

###### Global appearance, lighting simulation
```
@property (assign, nonatomic) LightingType simulatedLighting;
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
CBColorFinder is a component with two basic methods. First it allows for a color to be pulled from an image averaged at a point and then it also can return N of the most common colors seen in an image. Additionally, a CBColoring class provides useful methods for finding how close a color is to another, and color theory features useul to users. When combined together an interface to help users pull colors from their photos is available. Since it is a subclass of UIImageView, the image property will set the image utilized by this control.

###### CBColorFinder
Load an image into this control is very easy:
colorFinder.image = image

*Callback for when a color is touched.*
We use this method to move an eyedropper control around the interface with the current color
```
@property (nonatomic, copy) void(^colorTouchedAtPoint)(TouchStep touchType, CGPoint point, UIColor *color);
```

*Retrieve the most common colors for the current image:*
```
- (NSArray *) getMostCommonColors:(int)count type:(CBColorType)type;
```

#### CBColoring

Return complementary colors for a given color, with an angle tolerance in degrees.
```
+ (NSArray *)complementsForColor:(UIColor *)color count:(int)count angle:(double)angleSpan;
```

Return adjacent colors for a given color, with an angle tolerance in degrees.
```
+ (NSArray *)adjacentColors:(UIColor *)color count:(int)count angle:(double)angleSpan;
```

Return N number of shades for a given color.
```
+ (NSArray *)shadesOfColor:(UIColor *)color count:(int)count;
```

Get the euclidean distance between two colors, useful for finding the most appropriate match. A weight coefficient may be applied and it can operate under the HSV color space for more accurate results.
```
+ (double)distance:(UIColor *)colorA
         fromColor:(UIColor *)colorB;

+ (double)distance:(UIColor *)colorA
         fromColor:(UIColor *)colorB
             asHSV:(BOOL)asHSV
       coefficient:(CGFloat[3])coefficient;
```

Convert a color to HSV or HSL color spaces.
```
+ (void) convertRGB:(UIColor *)rgbColor toHSV:(CGFloat[3])hsv;
+ (void) convertRGB:(UIColor *)rgbColor toHSL:(CGFloat[3])hsl;
```
