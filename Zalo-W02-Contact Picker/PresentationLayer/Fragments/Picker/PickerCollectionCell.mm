//
//  PickerCollectionCell.m
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/11/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "PickerCollectionCell.h"
#import <Foundation/Foundation.h>

@interface PickerCollectionCell()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) PickerModel *model;

@end

@implementation PickerCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [_imageView clipsToBounds];
    _imageView.layer.cornerRadius = _imageView.layer.bounds.size.width / 2;
    
    [_removeButton clipsToBounds];
    _removeButton.layer.cornerRadius = _removeButton.layer.bounds.size.width / 2;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [_imageView setImage:nil];
    [_nameLabel setText:@""];
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
    
    if (pickerModel.imageData) {
        [_imageView setImage:[UIImage imageWithData:pickerModel.imageData]];
    } else {
        //TODO: Present gradient name avatar here
        
    }
}

- (IBAction)removeButtonTapped:(id)sender {
    if (_delegate) {
        [_delegate removeButtonTapped:_model];
    }
}


@end
