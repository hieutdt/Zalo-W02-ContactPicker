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

- (void)setAvatar:(UIImage*)avatarImage withColorCode:(int)colorCode {
    if (avatarImage) {
        //TODO: Show thumbnail avatar here
        _gradientAvatarLabel.hidden = true;
        [_avatarImageView setImage:avatarImage];
        _avatarImageView.layer.sublayers = nil;
    } else {
        //TODO: Show gradient avatar here
        _gradientAvatarLabel.hidden = false;
        _gradientAvatarLabel.text = [self getShortName:_nameLabel.text];
        [self setGradientColorBackground:colorCode];
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

- (void)setGradientColorBackground:(int)colorCode {
    switch (colorCode) {
        case GRADIENT_COLOR_RED: {
            [ColorHelper setRedGradientBackground:_avatarImageView];
            break;
        }
        case GRADIENT_COLOR_BLUE: {
            [ColorHelper setBlueGradientBackground:_avatarImageView];
            break;
        }
        case GRADIENT_COLOR_GREEN: {
            [ColorHelper setGreenGradientBackground:_avatarImageView];
            break;
        }
        case GRADIENT_COLOR_ORANGE: {
            [ColorHelper setOrangeGradientBackground:_avatarImageView];
            break;
        }
        default:
            break;
    }
}

- (void)showSeparatorLine:(BOOL)show {
    _separatorLine.hidden = !show;
}

- (NSData *)getImageData {
    return UIImageJPEGRepresentation(_avatarImageView.image, 0.7);
}

- (NSString *)getShortName:(NSString *)name {
    if (name.length == 0)
        return @"";
    
    NSMutableString *shortName = [[NSMutableString alloc] initWithFormat:@"%c", [name characterAtIndex:0]];
    
    for (int i = 0; i < name.length - 1; i++) {
        if ([[name substringWithRange:NSMakeRange(i, 1)] isEqualToString: @" "]) {
            [shortName appendString:[name substringWithRange:NSMakeRange(i + 1, 1)]];
            break;
        }
    }
    
    return shortName;
}


@end
