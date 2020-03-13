//
//  PickerTableViewCell.m
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/12/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "PickerTableViewCell.h"
#import "AppConsts.h"

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
    
    _checkImageView.image = nil;
    _avatarImageView.image = nil;
    _nameLabel.text = @"";
    _separatorLine.hidden = true;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:false animated:animated];
}

- (void)setName:(NSString*)name {
    _nameLabel.text = name;
}

- (void)setAvatar:(UIImage*)avatarImage {
    if (avatarImage) {
        [_avatarImageView setImage:avatarImage];
    } else {
        //TODO: Show gradient avatar here
        [_avatarImageView setBackgroundColor:[UIColor redColor]];
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
    _separatorLine.hidden = !show;
}

- (NSData *)getImageData {
    return UIImageJPEGRepresentation(_avatarImageView.image, 0.7);
}

@end
