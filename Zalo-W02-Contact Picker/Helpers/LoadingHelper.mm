//
//  LoadingHelper.m
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/17/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "LoadingHelper.h"
#import <JGProgressHUD/JGProgressHUD.h>
#import <UIKit/UIKit.h>

static LoadingHelper *sharedInstance = nil;

@interface LoadingHelper ()

@property (weak, nonatomic) UIWindow *keyWindow;
@property (strong, nonatomic) UIView *view;
@property (strong, nonatomic) JGProgressHUD *HUD;

@end

@implementation LoadingHelper

- (void)customInit {
    NSArray *windows = [UIApplication sharedApplication].windows;
    for (UIWindow *window in windows) {
        if ([window isKeyWindow]) {
            _keyWindow = window;
            break;
        }
    }
    
    _view = [[UIView alloc] initWithFrame:_keyWindow.bounds];
    _HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleLight];
    _HUD.textLabel.text = @"Loading";
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

+ (instancetype)instance {
    if (!sharedInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[LoadingHelper alloc] init];
        });
    }
    
    return sharedInstance;
}

- (void)showLoadingEffect {
    [_keyWindow addSubview:_view];
    [_HUD showInView:_view];
}

- (void)hideLoadingEffect {
    [_HUD dismissAnimated:true];
    [_view removeFromSuperview];
}

- (void)hideLoadingEffectDelay:(int)seconds {
    [_HUD dismissAfterDelay:seconds];
    
    sleep(seconds);
    [self.view removeFromSuperview];
}

@end
