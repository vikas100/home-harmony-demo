
#import <UIKit/UIKit.h>

@protocol CBDrawerControllerDelegate <NSObject>

@optional

- (void) CBDrawerController_drawerWillOpen:(id)drawer;
- (void) CBDrawerController_drawerWillClose:(id)drawer;

- (void) CBDrawerController_drawerDidOpen:(id)drawer;
- (void) CBDrawerController_drawerDidClose:(id)drawer;

@end

@interface CBDrawerController : NSObject

@property (assign, nonatomic) id <CBDrawerControllerDelegate> delegate;
@property (retain, nonatomic) UIView *sidebarView;
@property (retain, nonatomic) UIView *primaryView;
@property (readonly, nonatomic) BOOL isOpen;
@property (readonly, nonatomic) BOOL allowDragging;

- (id)initWithDelegate:(id <CBDrawerControllerDelegate>)delegate
           primaryView:(UIView *)primaryView
           sidebarView:(UIView *)sidebarView
           shadowImage:(UIImage *)shadowImage;

- (void)toggleDrawer:(BOOL)open;
- (void)toggleDrawer:(BOOL)open block:(void (^)(void))block animate:(BOOL)animate;

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *) event;
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *) event;

@end