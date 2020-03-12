//
//  PickerCollectionCell.h
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/11/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickerModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PickerCollectionCellDelegate <NSObject>

- (void)removeButtonTapped:(PickerModel*)pickerModel;

@end

@interface PickerCollectionCell : UICollectionViewCell

@property (weak, nonatomic) id<PickerCollectionCellDelegate> delegate;

+ (NSString*)reuseIdentifier;
+ (NSString*)nibName;

- (void)setUpPickerModelForCell:(PickerModel*)pickerModel;

@end

NS_ASSUME_NONNULL_END
