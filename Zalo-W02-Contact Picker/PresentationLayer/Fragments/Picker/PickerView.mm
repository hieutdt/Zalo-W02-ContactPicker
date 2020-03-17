//
//  PickerView.m
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/11/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "PickerView.h"
#import "PickerModel.h"
#import "PickerCollectionCell.h"
#import "AppConsts.h"

@interface PickerView() <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PickerCollectionCellDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (strong, nonatomic) NSMutableArray<PickerModel*> *dataArray;
@property (strong, nonatomic) NSCache<NSString *, NSData *> *dataImageCache;

@end



@implementation PickerView

- (void)customInit {
    UINib *nib = [UINib nibWithNibName:@"PickerView" bundle:nil];
    [nib instantiateWithOwner:self options:nil];
    
    _contentView.frame = self.bounds;
    [self addSubview:_contentView];
    
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    [self resigterNib];
    [self createNextButton];
    
    _dataArray = [[NSMutableArray alloc] init];
    _dataImageCache = [[NSCache alloc] init];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
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

- (void)createNextButton {
    _nextButton.layer.masksToBounds = false;
    _nextButton.layer.cornerRadius = _nextButton.bounds.size.width / 2;
    _nextButton.layer.shadowColor = [UIColor blackColor].CGColor;
    _nextButton.layer.shadowOpacity = 0.3;
    _nextButton.layer.shadowOffset = CGSizeZero;
    _nextButton.layer.shadowRadius = 3;
}

- (void)resigterNib {
    UINib *nib = [UINib nibWithNibName:PickerCollectionCell.nibName bundle:nil];
    [_collectionView registerNib:nib forCellWithReuseIdentifier:PickerCollectionCell.reuseIdentifier];
}

- (void)reloadData {
    [_collectionView reloadData];
}

- (void)addElement:(PickerModel *)pickerModel withImageData:(nonnull NSData *)imageData {
    if (_dataArray.count == MAX_PICK)
        return;
    
    self.hidden = false;
    
    [_collectionView performBatchUpdates:^{
        [_dataArray addObject:pickerModel];
        if (imageData)
            [_dataImageCache setObject:imageData forKey:pickerModel.identifier];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_dataArray.count - 1 inSection:0];
        [_collectionView insertItemsAtIndexPaths:@[indexPath]];
        
    } completion:^(BOOL finished) {
        [self scrollToBottom:self.collectionView];
        [self layoutIfNeeded];
    }];
}

- (void)removeElement:(PickerModel *)pickerModel {
    [_collectionView performBatchUpdates:^{
        NSUInteger indexInArray = [_dataArray indexOfObject:pickerModel];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexInArray inSection:0];
        
        [_dataArray removeObject:pickerModel];
        [_dataImageCache removeObjectForKey:pickerModel.identifier];
        [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
        
    } completion:^(BOOL finished) {
        self.hidden = (self.dataArray.count == 0);
        [self layoutIfNeeded];
    }];
}

- (void)removeAll {
    [_dataArray removeAllObjects];
    self.hidden = true;
    [self reloadData];
}

-(void)scrollToBottom:(UICollectionView*)collectionView {
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_dataArray.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}


#pragma mark - UICollectionViewDelegateProtocol


#pragma mark - UICollectionViewDataSourceProtocol

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PickerCollectionCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:PickerCollectionCell.reuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:PickerCollectionCell.nibName owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    //TODO: Set up for cell here
    [cell setUpPickerModelForCell:_dataArray[indexPath.row]];
    [cell setUpImageForCell:[_dataImageCache objectForKey:_dataArray[indexPath.row].identifier]];
    cell.delegate = self;
    
    return cell;
}

- (IBAction)nextButtonTapped:(id)sender {
    if (_delegate) {
        [_delegate nextButtonTapped];
    }
}


#pragma mark - UICollectionViewDelegateFlowLayoutProtocol

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    PickerCollectionCell *cell = [[[NSBundle mainBundle] loadNibNamed:PickerCollectionCell.nibName owner:self options:nil] objectAtIndex:0];
    
    if (!cell)
        return CGSizeZero;

    return CGSizeMake(PICKER_COLLECTION_CELL_WIDTH, PICKER_COLLECTION_CELL_HEIGHT);
}


#pragma mark - PickerCollectionViewDelegateProtocol

- (void)removeButtonTapped:(PickerModel *)pickerModel {
    [self removeElement:pickerModel];
    
    if (_delegate)
        [_delegate removeElementFromPickerview:pickerModel];
}

@end
