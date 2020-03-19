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

@property (weak, nonatomic) PickerModel *model;

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
    
    _imageView.layer.sublayers = nil;
    [_imageView setImage:nil];
}

+ (NSString*)reuseIdentifier {
    return @"PickerCollectionCell";
}

+ (NSString *)nibName {
    return @"PickerCollectionCell";
}

- (void)setUpPickerModelForCell:(PickerModel*)pickerModel {
    if (!pickerModel)
        return;
    
    _model = pickerModel;
    _gradientAvatarLabel.hidden = false;
    _gradientAvatarLabel.text = [StringHelper getShortName:_model.name];
    [ColorHelper setGradientColorBackgroundToView:_imageView withColorCode:_model.gradientColorCode];
}

- (void)setUpImageForCell:(UIImage *)image {
    if (image) {
        _gradientAvatarLabel.hidden = true;
        _imageView.layer.sublayers = nil;
        [_imageView setImage:image];
    }
}

- (IBAction)removeButtonTapped:(id)sender {
    if (_delegate and [_delegate respondsToSelector:@selector(removeButtonTapped:)]) {
        [_delegate removeButtonTapped:_model];
    }
}

@end
