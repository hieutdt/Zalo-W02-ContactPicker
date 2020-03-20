//
//  PickerTableViewCell.m
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/12/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "PickerTableViewCell.h"
#import "AppConsts.h"
#import "ColorHelper.h"
#import "StringHelper.h"

@interface PickerTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorLine;
@property (weak, nonatomic) IBOutlet UILabel *gradientAvatarLabel;

@property (strong, nonatomic) UIImage *checkedImage;
@property (strong, nonatomic) UIImage *uncheckImage;

@end

@implementation PickerTableViewCell

+ (NSString*)nibName {
    return @"PickerTableViewCell";
}

+ (NSString*)reuseIdentifier {
    return @"PickerTableViewCell";
}

- (void)awakeFromNib {
    [super awakeFromNib];
  
    [_avatarImageView clipsToBounds];
    _avatarImageView.layer.cornerRadius = _avatarImageView.bounds.size.width / 2;
    
    _checkedImage = [UIImage imageNamed:@"checked"];
    _uncheckImage = [[UIImage imageNamed:@"uncheck"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    _separatorLine.hidden = true;
    _gradientAvatarLabel.hidden = true;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.checkImageView.image = nil;
    self.avatarImageView.image = nil;
    self.avatarImageView.layer.sublayers = nil;
    self.nameLabel.text = @"";
    self.separatorLine.hidden = true;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:false animated:animated];
}

- (void)setName:(NSString*)name {
    _nameLabel.text = name;
}

- (void)setGradientColorBackground:(int)colorCode {
    //TODO: Show gradient avatar here
    self.gradientAvatarLabel.hidden = false;
    self.gradientAvatarLabel.text = [StringHelper getShortName:self.nameLabel.text];
    [ColorHelper setGradientColorBackgroundToView:self.avatarImageView withColorCode:colorCode];
}

- (void)setAvatar:(UIImage*)avatarImage {
    if (avatarImage) {
        //TODO: Show thumbnail avatar here
        self.gradientAvatarLabel.hidden = true;
        [self.avatarImageView setImage:avatarImage];
        self.avatarImageView.layer.sublayers = nil;
    }
}

- (void)setChecked:(BOOL)isChecked {
    [UIView transitionWithView:_checkImageView duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        if (isChecked) {
            [self.checkImageView setImage:self.checkedImage];
        } else {
            [self.checkImageView setImage:self.uncheckImage];
            [self.checkImageView setTintColor:[UIColor lightGrayColor]];
        }
    } completion:nil];
}

- (void)showSeparatorLine:(BOOL)show {
    self.separatorLine.hidden = !show;
}


@end
