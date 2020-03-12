//
//  PickerTableView.h
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/12/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickerModel.h"
#import "PickerTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PickerTableViewDelegate <NSObject>

- (UIImage*)getImageForCell:(PickerTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;
- (void)uncheckCellAtIndexPath:(NSIndexPath*)indexPath;
- (void)checkedCellAtIndexPath:(NSIndexPath*)indexPath;

@end

@interface PickerTableView : UIView

@property (nonatomic, assign) id<PickerTableViewDelegate> delegate;

- (void)setModelsData:(NSMutableArray<PickerModel*> *)modelsArray;
- (void)searchWithSearchString:(NSString*)searchString;
- (int)getSelectedCount;
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
