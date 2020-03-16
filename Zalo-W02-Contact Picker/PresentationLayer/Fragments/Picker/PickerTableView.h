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

- (void)loadImageToCell:(PickerTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)uncheckCellOfElement:(PickerModel *)element;
- (void)checkedCellOfElement:(PickerModel *)element withImageData:(NSData *)imageData;

@end

@interface PickerTableView : UIView

@property (nonatomic, assign) id<PickerTableViewDelegate> delegate;

- (void)setModelsData:(NSMutableArray<PickerModel *> *)modelsArray;
- (void)searchWithSearchString:(NSString*)searchString;
- (int)selectedCount;
- (void)reloadData;
- (void)removeElement:(PickerModel *)element;
- (void)removeAllElements;

@end

NS_ASSUME_NONNULL_END
