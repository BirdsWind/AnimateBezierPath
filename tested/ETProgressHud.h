//
//  CHEtalioPath.h
//  tested
//
//  Created by Cecilia Humlelu on 04/06/14.
//  Copyright (c) 2014 Cecilia Humlelu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETProgressHud : UIView


+ (void)show;
+ (void)showWithStatus:(NSString*)status;
+ (void)setStatus:(NSString*)string; // change the HUD loading status while it's showing

+ (void)dismiss; // simply dismiss the HUD with a fade+scale out animation
+ (void)dismissWithSuccess:(NSString*)successString; // also displays the success icon image
+ (void)dismissWithSuccess:(NSString*)successString afterDelay:(NSTimeInterval)seconds;
+ (void)dismissWithError:(NSString*)errorString; // also displays the error icon image
+ (void)dismissWithError:(NSString*)errorString afterDelay:(NSTimeInterval)seconds;




@end
