//
//  ImageCache.h
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/19/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageCache : NSObject

+ (instancetype)instance;

- (nullable UIImage *)imageForKey:(NSString *)key;
- (void)setImage:(UIImage *)image forKey:(NSString *)key;
- (void)removeImageForKey:(NSString *)key;
- (void)removeAllImages;

@end

NS_ASSUME_NONNULL_END
