//
//  ErrorView.m
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/17/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "ErrorView.h"
#import "LayoutHelper.h"

@interface ErrorView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *retryButton;
@property (nonatomic, nullable) void (^retryBlock)();

@end

@implementation ErrorView

- (void)customInit {
    UINib *nib = [UINib nibWithNibName:@"ErrorView" bundle:nil];
    [nib instantiateWithOwner:self options:nil];
    
    _contentView.frame = self.bounds;
    [self addSubview:_contentView];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    if (image) {
        [_imageView setImage:image];
    }
}

- (void)setTilte:(NSString *)title andDescription:(NSString *)description {
    _titleLabel.text = title;
    _descriptionLabel.text = description;
}

- (void)setRetryBlock:(void (^)())retryBlock {
    _retryBlock = retryBlock;
}

- (void)setRetryButtonTitle:(NSString *)buttonTitle {
    [_retryButton setTitle:buttonTitle forState:UIControlStateNormal];
}

- (IBAction)retryButtonTapped:(id)sender {
    if (_retryBlock) {
        _retryBlock();
    }
}

@end
