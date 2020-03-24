//
//  PickerModel.h
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/11/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PickerViewModel : NSObject

@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *name;
@property (nonatomic) BOOL isChosen;
@property (nonatomic) int gradientColorCode;

- (int)getSectionIndex;

@end

NS_ASSUME_NONNULL_END
