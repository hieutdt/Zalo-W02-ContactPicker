//
//  ErrorView.h
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/17/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ErrorView : UIView

- (void)setImage:(UIImage *)image;
- (void)setTilte:(NSString *)title andDescription:(NSString *)description;
- (void)setRetryBlock:(void (^)())retryBlock;

@end

NS_ASSUME_NONNULL_END
