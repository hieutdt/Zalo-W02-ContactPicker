//
//  PickerTableViewCell.h
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/12/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PickerTableViewCell : UITableViewCell

+ (NSString*)nibName;
+ (NSString*)reuseIdentifier;

- (void)setName:(NSString *)name;
- (void)setAvatar:(UIImage *)avatarImage;
- (void)setGradientColorBackground:(int)colorCode;
- (void)setChecked:(BOOL)isChecked;
- (void)showSeparatorLine:(BOOL)show;

@end

NS_ASSUME_NONNULL_END
