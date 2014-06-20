//
//  CHEtalioPath.m
//  tested
//
//  Created by Cecilia Humlelu on 04/06/14.
//  Copyright (c) 2014 Cecilia Humlelu. All rights reserved.
//

#import "ETProgressHud.h"
#import <QuartzCore/QuartzCore.h>


CGFloat const hudWidth = 136;
CGFloat const hudHeight = 110;


NSTimeInterval const animationOneDuration = 1.0;
NSTimeInterval  const animationTwoDuration = 0.05;
NSTimeInterval const animationThreeDuration = 0.7;
double const delayInSeconds = 0.2;


@interface ETProgressHud()

@property CALayer *etalioLayerGroup;
@property CALayer *etalioBackgroundLayer;
@property CAShapeLayer *etalioLogoOuterLayer;
@property CAShapeLayer *etalioLogoCrossLayer;
@property CAShapeLayer *etalioLogoInnerLayer;
@property CALayer *etalioMaskLayer;

@property (nonatomic, readonly) UIWindow *overlayWindow;
@property (nonatomic, readonly) UIView *hudView;
@property (nonatomic, strong) UIToolbar *fakeView;
@property (nonatomic, readonly) UILabel *stringLabel;
@property (nonatomic, strong) NSTimer *fadeOutTimer;

@property (nonatomic, retain) UIImageView *imageView;

@end


@implementation ETProgressHud

static ETProgressHud *sharedView = nil;

@synthesize hudView,fadeOutTimer,overlayWindow,stringLabel,imageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
         self.backgroundColor =[UIColor redColor];
        [self.overlayWindow addSubview:self];
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
    }
    return self;
}


+ (ETProgressHud*)sharedView {
	
	if(sharedView == nil)
		sharedView = [[ETProgressHud alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	return sharedView;
}

- (void)setFadeOutTimer:(NSTimer *)newTimer {
    
    if(fadeOutTimer) {
        [fadeOutTimer invalidate];
        fadeOutTimer = nil;
    }
    
    if(newTimer)
        fadeOutTimer = newTimer;
}

+ (void)setStatus:(NSString *)string {
	[[ETProgressHud sharedView] setStatus:string];
}

#pragma  mark show
+ (void)show;{
    [ETProgressHud showWithStatus:nil];
}

+(void)showWithStatus:(NSString *)status;{
    [[self sharedView] showProgressStatus:status];
}


- (void)showProgressStatus:(NSString*)status;{
     self.hudView.backgroundColor = [UIColor clearColor];
    if(![self.subviews containsObject:self.fakeView]) {
        self.fakeView = [[UIToolbar alloc] initWithFrame:self.hudView.frame]; // .bounds or .frame? Not really sure!
        self.fakeView.autoresizingMask = self.hudView.autoresizingMask;
        self.fakeView.layer.cornerRadius = 8;
        self.fakeView.layer.masksToBounds = YES;
        [self.hudView insertSubview: self.fakeView atIndex:0];
        [self.hudView sendSubviewToBack:self.fakeView ];
    }
    self.fadeOutTimer = nil;
    [self.hudView addSubview:self.stringLabel];
    
  
    
    
    [self setStatus:status];
    if (hudView) {
        [self.hudView bringSubviewToFront:self.stringLabel];
    }
    [self.overlayWindow makeKeyAndVisible];
    [self positionHUD:nil];
    
    if(self.alpha != 1) {
        [self registerNotifications];
        self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1.3, 1.3);
        
        [UIView animateWithDuration:0.15
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1/1.3, 1/1.3);
                             self.alpha = 1;
                         }
                         completion:NULL];
    }
    
    [self setNeedsDisplay];
}





#pragma  mark  private methods

- (void)setStatus:(NSString *)string {
	
    CGRect labelRect = CGRectZero;
	
	if(string){
        
        CGSize maximumLabelSize = CGSizeMake(200, 300);
        CGRect textRect = [string boundingRectWithSize:maximumLabelSize
                                                 options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                              attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16.0]}
                                                 context:nil];
       
		labelRect = CGRectMake(0, 78, hudWidth, textRect.size.height);
	}
		
	self.stringLabel.hidden = NO;
	self.stringLabel.text = string;
	self.stringLabel.frame = labelRect;
	
}




- (void)registerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
}



- (void)positionHUD:(NSNotification*)notification {
    
    CGFloat keyboardHeight;
    double animationDuration = 0.0;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(notification) {
        NSDictionary* keyboardInfo = [notification userInfo];
        CGRect keyboardFrame = [[keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        animationDuration = [[keyboardInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        if(notification.name == UIKeyboardWillShowNotification || notification.name == UIKeyboardDidShowNotification) {
            if(UIInterfaceOrientationIsPortrait(orientation))
                keyboardHeight = keyboardFrame.size.height;
            else
                keyboardHeight = keyboardFrame.size.width;
        } else
            keyboardHeight = 0;
    } else {
        keyboardHeight = self.visibleKeyboardHeight;
    }
    
    CGRect orientationFrame = [UIScreen mainScreen].bounds;
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    
    if(UIInterfaceOrientationIsLandscape(orientation)) {
        float temp = orientationFrame.size.width;
        orientationFrame.size.width = orientationFrame.size.height;
        orientationFrame.size.height = temp;
        
        temp = statusBarFrame.size.width;
        statusBarFrame.size.width = statusBarFrame.size.height;
        statusBarFrame.size.height = temp;
    }
    
    CGFloat activeHeight = orientationFrame.size.height;
    
    if(keyboardHeight > 0)
        activeHeight += statusBarFrame.size.height*2;
    
    activeHeight -= keyboardHeight;
    CGFloat posY = floor(activeHeight*0.45);
    CGFloat posX = orientationFrame.size.width/2;
    
    CGPoint newCenter;
    CGFloat rotateAngle;
    
    switch (orientation) {
        case UIInterfaceOrientationPortraitUpsideDown:
            rotateAngle = M_PI;
            newCenter = CGPointMake(posX, orientationFrame.size.height-posY);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            rotateAngle = -M_PI/2.0f;
            newCenter = CGPointMake(posY, posX);
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotateAngle = M_PI/2.0f;
            newCenter = CGPointMake(orientationFrame.size.height-posY, posX);
            break;
        default: // as UIInterfaceOrientationPortrait
            rotateAngle = 0.0;
            newCenter = CGPointMake(posX, posY);
            break;
    }
    
    if(notification) {
        [UIView animateWithDuration:animationDuration
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             [self moveToPoint:newCenter rotateAngle:rotateAngle];
                         } completion:NULL];
    }
    
    else {
        [self moveToPoint:newCenter rotateAngle:rotateAngle];
    }
    
}

- (void)moveToPoint:(CGPoint)newCenter rotateAngle:(CGFloat)angle {
    self.hudView.transform = CGAffineTransformMakeRotation(angle);
    self.hudView.center = newCenter;
}


- (CGFloat)visibleKeyboardHeight {
    
    //    NSAutoreleasePool *autoreleasePool = [[NSAutoreleasePool alloc] init];
    
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in [[UIApplication sharedApplication] windows]) {
        if(![[testWindow class] isEqual:[UIWindow class]]) {
            keyboardWindow = testWindow;
            break;
        }
    }
	
    // Locate UIKeyboard.
    UIView *foundKeyboard = nil;
    for (__strong UIView *possibleKeyboard in [keyboardWindow subviews]) {
        
        // iOS 4 sticks the UIKeyboard inside a UIPeripheralHostView.
        if ([[possibleKeyboard description] hasPrefix:@"<UIPeripheralHostView"]) {
            possibleKeyboard = [[possibleKeyboard subviews] objectAtIndex:0];
        }
        
        if ([[possibleKeyboard description] hasPrefix:@"<UIKeyboard"]) {
            foundKeyboard = possibleKeyboard;
            break;
        }
    }
    
    //    [autoreleasePool drain];
	
    if(foundKeyboard && foundKeyboard.bounds.size.height > 100)
        return foundKeyboard.bounds.size.height;
    
    return 0;
}






#pragma mark - Dismiss Methods
+ (void)dismiss; {
    [[ETProgressHud sharedView] dismiss];
}
+ (void)dismissWithSuccess:(NSString*)successString; {
    
}// also displays the success icon image
+ (void)dismissWithSuccess:(NSString*)successString afterDelay:(NSTimeInterval)seconds;{
    
    [[self sharedView] dismissWithStatus:successString error:NO afterDelay:seconds];
    
}
+ (void)dismissWithError:(NSString*)errorString; {
    [[ETProgressHud sharedView] dismissWithStatus:errorString error:YES afterDelay:0];
}// also displays the error icon image
+ (void)dismissWithError:(NSString*)errorString afterDelay:(NSTimeInterval)seconds;{
     [[ETProgressHud sharedView] dismissWithStatus:errorString error:YES afterDelay:seconds];
}


- (void)dismissWithStatus:(NSString *)string error:(BOOL)error afterDelay:(NSTimeInterval)seconds {
    
    if(self.alpha != 1)
        return;

	
	if(error)
		self.imageView.image = [UIImage imageNamed:@"error.png"];
	else
		self.imageView.image = [UIImage imageNamed:@"success.png"];
	
	self.imageView.hidden = NO;
	
	[self setStatus:string];
	
    
	self.fadeOutTimer = [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
}


-(void)dismiss;{
    
	[UIView animateWithDuration:0.15
						  delay:0
						options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 sharedView.hudView.transform = CGAffineTransformScale(sharedView.hudView.transform, 0.8, 0.8);
						 sharedView.alpha = 0;
					 }
					 completion:^(BOOL finished){
                         if(finished) {
                             [[NSNotificationCenter defaultCenter] removeObserver:sharedView];
                           //  overlayWindow = nil;
                             sharedView = nil;
                             
                             // find the frontmost window that is an actual UIWindow and make it keyVisible
                             [[UIApplication sharedApplication].windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIWindow *window, NSUInteger idx, BOOL *stop) {
                                 if([window isKindOfClass:[UIWindow class]] && window.windowLevel == UIWindowLevelNormal) {
                                     [window makeKeyWindow];
                                     *stop = YES;
                                 }
                             }];
                             
                             // uncomment to make sure UIWindow is gone from app.windows
                             // DLog(@"%@", [UIApplication sharedApplication].windows);
                             // DLog(@"keyWindow = %@", [UIApplication sharedApplication].keyWindow);
                         }
                     }];

}




#pragma  mark subviews 

- (UIView *)hudView {
    
    if(!hudView) {
        hudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, hudWidth, hudHeight)];
		[self addSubview:hudView];
        [self setup];
        }
    return hudView;
}


- (UILabel *)stringLabel {
    if (stringLabel == nil) {
        stringLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		stringLabel.textColor = [UIColor colorWithWhite:(1.0f/255)*85.0f alpha:1.0f];
		stringLabel.backgroundColor = [UIColor clearColor];
		stringLabel.adjustsFontSizeToFitWidth = YES;
		stringLabel.textAlignment = NSTextAlignmentCenter;
		stringLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		stringLabel.font = [UIFont boldSystemFontOfSize:14];
        stringLabel.numberOfLines = 0;
		[self.hudView addSubview:stringLabel];
    }
    return stringLabel;
}


- (UIImageView *)imageView {
    if (imageView == nil) {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
		[self.hudView addSubview:imageView];
    }
    return imageView;
}


- (UIWindow *)overlayWindow {
    if(!overlayWindow) {
        overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        overlayWindow.backgroundColor = [UIColor clearColor];
        overlayWindow.userInteractionEnabled = NO;
    }
    return overlayWindow;
}


-(void)setup;{
    
    self.etalioLayerGroup = [CALayer layer];
    self.etalioLayerGroup.frame = CGRectMake((hudWidth - 60)/2, 13, 60, 60);
    // self.etalioLayerGroup.backgroundColor = [UIColor clearColor].CGColor;
    self.etalioLayerGroup.contents = (id)[UIImage imageNamed:@"backPlate"].CGImage;
    [self.hudView.layer addSublayer:self.etalioLayerGroup];
    
    self.etalioBackgroundLayer = [self createEtalioMaskLayerWithImageString:@"background" andFrame:CGRectMake(0, 0, 60, 60)];
    self.etalioLogoOuterLayer = [self createEtalioLogoOuterLayer];
    self.etalioLogoCrossLayer = [self createEtalioLogoCrossLayer];
    self.etalioLogoInnerLayer = [self createEtalioLogoInnerLayer];
    self.etalioMaskLayer = [self createEtalioMaskLayerWithImageString:@"etalio-mask" andFrame:CGRectMake(0, 0, 60, 60)];
    
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        self.etalioLogoOuterLayer.contentsScale = [[UIScreen mainScreen] scale];
        self.etalioLogoCrossLayer.contentsScale = [[UIScreen mainScreen] scale];
        self.etalioLogoInnerLayer.contentsScale = [[UIScreen mainScreen] scale];
        self.etalioMaskLayer.contentsScale = [[UIScreen mainScreen] scale];
        ;
    }
#endif
    
    [self.etalioLayerGroup addSublayer:self.etalioBackgroundLayer];
    [self.etalioLayerGroup addSublayer:self.etalioLogoOuterLayer];
    [self.etalioLayerGroup addSublayer:self.etalioMaskLayer];
    
    [self animateEtalioLogoOuterLayer];
    
}

-(CAShapeLayer *)createEtalioLogoOuterLayer;{
    CAShapeLayer *aLayer = [CAShapeLayer layer];
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    
    [aPath moveToPoint:CGPointMake(13, 36)];
    [aPath addLineToPoint:CGPointMake(13, 47)];
    [aPath addLineToPoint:CGPointMake(47, 47)];
    [aPath addLineToPoint:CGPointMake(47, 13)];
    [aPath addLineToPoint:CGPointMake(13, 13)];
    [aPath addLineToPoint:CGPointMake(13, 30)];
    [aPath addLineToPoint:CGPointMake(19, 30)];
    
    aLayer.path = aPath.CGPath;
    aLayer.fillColor = [UIColor clearColor].CGColor;
    aLayer.strokeColor = [UIColor whiteColor].CGColor;
    aLayer.lineWidth = 8;
    
    return aLayer;
}


-(CAShapeLayer *)createEtalioLogoCrossLayer;{
    CAShapeLayer *aLayer = [CAShapeLayer layer];
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    
    [aPath moveToPoint:CGPointMake(18, 30.2)];
    [aPath addLineToPoint:CGPointMake(24, 30.2)];
    
    [aPath closePath];
    aLayer.path = aPath.CGPath;
    aLayer.fillColor = [UIColor clearColor].CGColor;
    aLayer.strokeColor = [UIColor whiteColor].CGColor;
    aLayer.lineWidth = 4.5;
    return aLayer;
    
}



-(CAShapeLayer *)createEtalioLogoLayer;{
    CAShapeLayer *aLayer = [CAShapeLayer layer];
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    
    [aPath moveToPoint:CGPointMake(13, 36)];
    [aPath addLineToPoint:CGPointMake(13, 47)];
    [aPath addLineToPoint:CGPointMake(47, 47)];
    
    [aPath addLineToPoint:CGPointMake(47, 13)];
    [aPath addLineToPoint:CGPointMake(13, 13)];
    
    
    [aPath addLineToPoint:CGPointMake(13, 30)];
    [aPath addLineToPoint:CGPointMake(39, 30)];
    [aPath addLineToPoint:CGPointMake(39, 21)];
    
    [aPath addLineToPoint:CGPointMake(22, 21)];
    [aPath addLineToPoint:CGPointMake(22, 38)];
    [aPath addLineToPoint:CGPointMake(40, 38)];
    
    aPath.lineCapStyle = kCGLineCapRound;
    aPath.lineJoinStyle = kCGLineJoinBevel;
    
    aLayer.path = aPath.CGPath;
    aLayer.fillColor = [UIColor clearColor].CGColor;
    aLayer.strokeColor = [UIColor purpleColor].CGColor;
    aLayer.lineWidth = 8;
    
    return aLayer;
}

-(CAShapeLayer *)createEtalioLogoInnerLayer;{
    CAShapeLayer *aLayer = [CAShapeLayer layer];
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    
    [aPath moveToPoint:CGPointMake(24, 30)];
    [aPath addLineToPoint:CGPointMake(39, 30)];
    [aPath addLineToPoint:CGPointMake(39, 21)];
    
    [aPath addLineToPoint:CGPointMake(22, 21)];
    [aPath addLineToPoint:CGPointMake(22, 38)];
    [aPath addLineToPoint:CGPointMake(40, 38)];
    
    
    aPath.lineCapStyle = kCGLineCapRound;
    aPath.lineJoinStyle = kCGLineJoinBevel;
    aLayer.path = aPath.CGPath;
    aLayer.fillColor = [UIColor clearColor].CGColor;
    aLayer.strokeColor = [UIColor whiteColor].CGColor;
    aLayer.lineWidth = 8;
    
    return aLayer;
    
}


-(CALayer *)createEtalioMaskLayerWithImageString:(NSString *)string andFrame:(CGRect) rect;{
    
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = rect;
    imageLayer.contentsGravity = kCAGravityResizeAspect;
    imageLayer.contents = (id)[UIImage imageNamed:string].CGImage;
    imageLayer.masksToBounds = YES;
    imageLayer.cornerRadius = 8;
    imageLayer.borderColor = [UIColor colorWithRed:97.0/255.0 green:197.0/255.0 blue:0.0/255.0 alpha:1].CGColor;
    imageLayer.borderWidth = 3.0f;
    
    return imageLayer;
    
}


-(void)animateEtalioLogoOuterLayer;{
    
  
    
    CABasicAnimation *animationOne = [CABasicAnimation animationWithKeyPath: @"strokeEnd"];
    [animationOne setFromValue:[NSNumber numberWithInt:0]];
    [animationOne setToValue:[NSNumber numberWithInt:1]];
    
    animationOne.beginTime = CACurrentMediaTime(); //Start instantly.
    animationOne.duration = animationOneDuration;
    animationOne.delegate = self;
    [animationOne setValue:@"animationOne" forKey:@"strokeEndOne"];
    
    [self.etalioLogoOuterLayer addAnimation:animationOne forKey:@"strokeEndOne"];
}


-(void) animateEtalioLogoCrossLayer;{
    if(self.etalioLogoCrossLayer.superlayer == self.etalioLayerGroup)
        [self.etalioLogoCrossLayer removeFromSuperlayer];
    
    [self.etalioLayerGroup addSublayer:self.etalioLogoCrossLayer];
    [self bringSublayerToFront:self.etalioMaskLayer];
    
    
    CABasicAnimation *animationTwo = [CABasicAnimation animationWithKeyPath: @"strokeEnd"];
    animationTwo.beginTime = 0; //Start after animation one.
    animationTwo.duration = animationTwoDuration;
    
    [animationTwo setFromValue:[NSNumber numberWithInt:0]];
    [animationTwo setToValue:[NSNumber numberWithInt:1]];
    animationTwo.delegate = self;
    [animationTwo setValue:@"animationTwo" forKey:@"strokeEndTwo"];
    [self.etalioLogoCrossLayer addAnimation:animationTwo forKey:@"strokeEndTwo"];
}


-(void)animateEtalioLogoInnerLayer;{
    if(self.etalioLogoInnerLayer.superlayer == self.etalioLayerGroup)
        [self.etalioLogoInnerLayer removeFromSuperlayer];
    
    [self.etalioLayerGroup addSublayer:self.etalioLogoInnerLayer];
    [self bringSublayerToFront:self.etalioMaskLayer];
    
    
    CABasicAnimation *animationThree = [CABasicAnimation animationWithKeyPath: @"strokeEnd"];
    animationThree.beginTime = 0; //Start after animation one.
    animationThree.duration = animationThreeDuration;
    
    [animationThree setFromValue:[NSNumber numberWithInt:0]];
    [animationThree setToValue:[NSNumber numberWithInt:1]];
    animationThree.delegate = self;
    [self.etalioLogoInnerLayer addAnimation:animationThree forKey:@"strokeEndThree"];
    
}


- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag{
    
    if([[theAnimation valueForKey:@"strokeEndOne"] isEqual:@"animationOne"]) {
        [self animateEtalioLogoCrossLayer];
    }
    else if ([[theAnimation valueForKey:@"strokeEndTwo"] isEqual:@"animationTwo"]){
        [self animateEtalioLogoInnerLayer];
    }
    else{
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if(self.etalioLogoInnerLayer.superlayer == self.etalioLayerGroup)
                [self.etalioLogoInnerLayer removeFromSuperlayer];
            
            if(self.etalioLogoCrossLayer.superlayer == self.etalioLayerGroup)
                [self.etalioLogoCrossLayer removeFromSuperlayer];
            
            [self animateEtalioLogoOuterLayer];
        });
    }
}



- (void) bringSublayerToFront:(CALayer *)layer
{
    [layer removeFromSuperlayer];
    [self.etalioLayerGroup insertSublayer:layer atIndex:[self.etalioLayerGroup.sublayers count]];
}

- (void) sendSublayerToBack:(CALayer *)layer
{
    [layer removeFromSuperlayer];
    [self.etalioLayerGroup insertSublayer:layer atIndex:0];
}





@end
