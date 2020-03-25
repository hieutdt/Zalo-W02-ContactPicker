//
//  PickerView.m
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/11/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "PickerView.h"
#import "PickerViewModel.h"
#import "PickerCollectionCell.h"
#import "AppConsts.h"

@interface PickerView() <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PickerCollectionCellDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (strong, nonatomic) NSMutableArray<PickerViewModel *> *dataArray;
@property (strong, nonatomic) NSCache<NSString *, UIImage *> *imageCache;

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
    _imageCache = [[NSCache alloc] init];
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
    self.nextButton.layer.masksToBounds = false;
    self.nextButton.layer.cornerRadius = self.nextButton.bounds.size.width / 2;
    self.nextButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.nextButton.layer.shadowOpacity = 0.3;
    self.nextButton.layer.shadowOffset = CGSizeZero;
    self.nextButton.layer.shadowRadius = 3;
}

- (void)resigterNib {
    UINib *nib = [UINib nibWithNibName:PickerCollectionCell.nibName bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:PickerCollectionCell.reuseIdentifier];
}

- (void)reloadData {
    [self.collectionView reloadData];
}

- (void)addElement:(PickerViewModel *)pickerModel withImage:(nonnull UIImage *)image {
    if (self.dataArray.count == MAX_PICK)
        return;
    
    self.hidden = false;
    
    [self.collectionView performBatchUpdates:^{
        [self.dataArray addObject:pickerModel];
        if (image)
            [self.imageCache setObject:image forKey:pickerModel.identifier];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_dataArray.count - 1 inSection:0];
        [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
        
    } completion:^(BOOL finished) {
        [self scrollToBottom:self.collectionView];
        [self layoutIfNeeded];
    }];
}

- (void)removeElement:(PickerViewModel *)pickerModel {
    [self.collectionView performBatchUpdates:^{
        NSUInteger indexInArray = [self.dataArray indexOfObject:pickerModel];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexInArray inSection:0];
        
        [self.dataArray removeObject:pickerModel];
        [self.imageCache removeObjectForKey:pickerModel.identifier];
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        
    } completion:^(BOOL finished) {
        self.hidden = (self.dataArray.count == 0);
        [self layoutIfNeeded];
    }];
}

- (void)removeAllElements {
    [self.dataArray removeAllObjects];
    [self setHidden:YES];
    [self reloadData];
}

-(void)scrollToBottom:(UICollectionView*)collectionView {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.dataArray.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:true];
}


#pragma mark - UICollectionViewDelegateProtocol


#pragma mark - UICollectionViewDataSourceProtocol

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PickerCollectionCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:PickerCollectionCell.reuseIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:PickerCollectionCell.nibName owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    // Set up for cell here
    [cell setUpPickerModelForCell:_dataArray[indexPath.row]];
    [cell setUpImageForCell:[self.imageCache objectForKey:_dataArray[indexPath.row].identifier]];
    cell.delegate = self;
    
    return cell;
}

- (IBAction)nextButtonTapped:(id)sender {
    if (self.delegate and [self.delegate respondsToSelector:@selector(nextButtonTappedFromPickerView:)]) {
        [self.delegate nextButtonTappedFromPickerView:self];
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

- (void)pickerCollectionCell:(UICollectionViewCell *)cell removeButtonTapped:(PickerViewModel *)pickerModel {
    [self removeElement:pickerModel];
    
    if (self.delegate and [self.delegate respondsToSelector:@selector(pickerView:removeElement:)]) {
        [self.delegate pickerView:self removeElement:pickerModel];
    }
}

@end
