//
//  ColorHelper.m
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/16/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "ColorHelper.h"
#import "AppConsts.h"

@implementation ColorHelper

+ (void)setGradientColorBackgroundToView:(UIView *)view withColorCode:(int)colorCode {
    switch (colorCode) {
        case GRADIENT_COLOR_RED: {
            [ColorHelper setRedGradientBackground:view];
            break;
        }
        case GRADIENT_COLOR_BLUE: {
            [ColorHelper setBlueGradientBackground:view];
            break;
        }
        case GRADIENT_COLOR_GREEN: {
            [ColorHelper setGreenGradientBackground:view];
            break;
        }
        case GRADIENT_COLOR_ORANGE: {
            [ColorHelper setOrangeGradientBackground:view];
            break;
        }
        default:
            break;
    }
}

+ (void)setGradientColorBackground:(UIColor *)firstColor andSecondColor:(UIColor *)secondColor toView:(UIView *)view {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.startPoint = CGPointZero;
    gradient.endPoint = CGPointMake(1, 1);
    gradient.colors = [NSArray arrayWithObjects:(id)firstColor.CGColor,(id)secondColor.CGColor, nil];
    
    [view.layer insertSublayer:gradient atIndex:0];
}

+ (void)setBlueGradientBackground:(UIView *)view {
    [ColorHelper setGradientColorBackground:[UIColor colorWithRed:34/255.f green:211/255.f blue:198/255.f alpha:1] andSecondColor:[UIColor colorWithRed:145/255.f green:72/255.f blue:203/255.f alpha:1] toView:view];
}

+ (void)setRedGradientBackground:(UIView *)view {
    [ColorHelper setGradientColorBackground:[UIColor colorWithRed:255/255.f green:51/255.f blue:51/255.f alpha:1] andSecondColor:[UIColor colorWithRed:255/255.f green:128/255.f blue:128/255.f alpha:1] toView:view];
}

+ (void)setOrangeGradientBackground:(UIView *)view {
    [ColorHelper setGradientColorBackground:[UIColor colorWithRed:255/255.f green:153/255.f blue:51/255.f alpha:1] andSecondColor:[UIColor colorWithRed:255/255.f green:191/255.f blue:128/255.f alpha:1] toView:view];
}

+ (void)setGreenGradientBackground:(UIView *)view {
    [ColorHelper setGradientColorBackground:[UIColor colorWithRed:51/255.f green:255/255.f blue:51/255.f alpha:1] andSecondColor:[UIColor colorWithRed:57/255.f green:163/255.f blue:41/255.f alpha:1] toView:view];
}

@end
