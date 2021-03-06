//
//  PickerView.h
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/11/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickerViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PickerViewDelegate <NSObject>

- (void)pickerView:(UIView *)pickerView removeElement:(PickerViewModel *)pickerModel;
- (void)nextButtonTappedFromPickerView:(UIView *)pickerView;

@end

@interface PickerView : UIView

@property (nonatomic, assign) id<PickerViewDelegate> delegate;

- (void)addElement:(PickerViewModel *)pickerModel withImage:(UIImage *)image;
- (void)removeElement:(PickerViewModel *)pickerModel;
- (void)removeAllElements;

@end

NS_ASSUME_NONNULL_END
