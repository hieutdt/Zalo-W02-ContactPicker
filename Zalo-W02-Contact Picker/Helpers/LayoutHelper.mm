//
//  LayoutHelper.m
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/13/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "LayoutHelper.h"

@implementation LayoutHelper

+ (void)fitToParent:(UIView *)view {
    if (!view.superview)
        return;
    
    view.translatesAutoresizingMaskIntoConstraints = false;
    [view.topAnchor constraintEqualToAnchor:view.superview.topAnchor].active = true;
    [view.bottomAnchor constraintEqualToAnchor:view.superview.bottomAnchor].active = true;
    [view.leadingAnchor constraintEqualToAnchor:view.superview.leadingAnchor].active = true;
    [view.trailingAnchor constraintEqualToAnchor:view.superview.trailingAnchor].active = true;
}

@end
