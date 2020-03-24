//
//  PickerCollectionCell.m
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/11/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "PickerCollectionCell.h"
#import <Foundation/Foundation.h>
#import "ColorHelper.h"
#import "StringHelper.h"

@interface PickerCollectionCell()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *removeButtonContainer;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;
@property (weak, nonatomic) IBOutlet UILabel *gradientAvatarLabel;

@property (weak, nonatomic) PickerViewModel *model;

@end

@implementation PickerCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [_imageView clipsToBounds];
    _imageView.layer.cornerRadius = _imageView.layer.bounds.size.height / 2;
    
    [_removeButtonContainer clipsToBounds];
    _removeButtonContainer.layer.cornerRadius = _removeButtonContainer.bounds.size.width / 2;
    
    [_removeButton clipsToBounds];
    _removeButton.layer.cornerRadius = _removeButton.layer.bounds.size.width / 2;
    
    _gradientAvatarLabel.hidden = true;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.imageView.layer.sublayers = nil;
    [self.imageView setImage:nil];
}

+ (NSString*)reuseIdentifier {
    return @"PickerCollectionCell";
}

+ (NSString *)nibName {
    return @"PickerCollectionCell";
}

- (void)setUpPickerModelForCell:(PickerViewModel *)pickerModel {
    if (!pickerModel)
        return;
    
    self.model = pickerModel;
    self.gradientAvatarLabel.hidden = false;
    self.gradientAvatarLabel.text = [StringHelper getShortName:self.model.name];
    [ColorHelper setGradientColorBackgroundToView:self.imageView withColorCode:self.model.gradientColorCode];
}

- (void)setUpImageForCell:(UIImage *)image {
    if (image) {
        self.gradientAvatarLabel.hidden = true;
        self.imageView.layer.sublayers = nil;
        [self.imageView setImage:image];
    }
}

- (IBAction)removeButtonTapped:(id)sender {
    if (self.delegate and [self.delegate respondsToSelector:@selector(pickerCollectionCell:removeButtonTapped:)]) {
        [self.delegate pickerCollectionCell:self removeButtonTapped:self.model];
    }
}

@end
