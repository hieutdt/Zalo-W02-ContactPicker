//
//  LoadingHelper.h
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/17/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoadingHelper : NSObject

+ (instancetype)instance;
- (void)showLoadingEffect;
- (void)hideLoadingEffect;
- (void)hideLoadingEffectDelay:(int)seconds;

@end

NS_ASSUME_NONNULL_END
