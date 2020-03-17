//
//  StringHelper.h
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/12/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StringHelper : NSObject

+ (NSString*)standardizeString:(NSString*)string;
+ (NSString *)getShortName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
