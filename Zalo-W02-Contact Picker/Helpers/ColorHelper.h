//
//  ColorHelper.h
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/16/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ColorHelper : NSObject

+ (void)setGradientColorBackgroundToView:(UIView *)view withColorCode:(int)colorCode;
+ (void)setGradientColorBackground:(UIColor *)firstColor andSecondColor:(UIColor *)secondColor toView:(UIView *)view;
+ (void)setBlueGradientBackground:(UIView *)view;
+ (void)setGreenGradientBackground:(UIView *)view;
+ (void)setRedGradientBackground:(UIView *)view;
+ (void)setOrangeGradientBackground:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
