//
//  PickerModel.m
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/11/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "PickerViewModel.h"
#import "AppConsts.h"

@implementation PickerViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _identifier = [[NSString alloc] init];
        _name = [[NSString alloc] init];
        _isChosen = false;
        _gradientColorCode = RAND_FROM_TO(0, 3);
    }
    return self;
}

- (int)getSectionIndex {
    if (_name.length == 0)
        return -1;
    
    return [[_name lowercaseString] characterAtIndex:0] - FIRST_ALPHABET_ASCII_CODE;
}

@end
