//
//  PickerModel.m
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/11/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "PickerModel.h"
#import "AppConsts.h"

@implementation PickerModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _name = [[NSString alloc] init];
        _imageData = [[NSData alloc] init];
    }
    return self;
}

- (int)getSectionIndex {
    if (_name.length == 0)
        return -1;
    
    return [[_name lowercaseString] characterAtIndex:0] - FIRST_ALPHABET_ASCII_CODE;
}

@end
