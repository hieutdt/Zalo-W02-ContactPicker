//
//  PickerTableView.m
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/12/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "PickerTableView.h"
#import "PickerTableViewCell.h"
#import "PickerModel.h"
#import "AppConsts.h"

@interface PickerTableView() <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray<PickerModel*> *pickerModels;
@property (strong, nonatomic) NSMutableArray<NSMutableArray*> *sectionsArray;

@property (strong, nonatomic) NSMutableArray<PickerModel*> *filteredPickerModels;
@property (strong, nonatomic) NSMutableArray<NSMutableArray*> *filteredSectionsArray;

@property (nonatomic) BOOL isSearching;
@property (nonatomic) int selectedCount;

@end

@implementation PickerTableView

- (void)customInit {
    UINib *nib = [UINib nibWithNibName:@"PickerTableView" bundle:nil];
    [nib instantiateWithOwner:self options:nil];
    
    _contentView.frame = self.bounds;
    [self addSubview:_contentView];
    
    self.backgroundColor = [UIColor whiteColor];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _pickerModels = [[NSMutableArray alloc] init];
    _sectionsArray = [[NSMutableArray alloc] init];
    _filteredPickerModels = [[NSMutableArray alloc] init];
    _filteredSectionsArray = [[NSMutableArray alloc] init];
    
    _isSearching = false;
    _selectedCount = 0;
    
    [self resigterNib];
}

- (void)resigterNib {
    UINib *nib = [UINib nibWithNibName:PickerTableViewCell.nibName bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:PickerTableViewCell.reuseIdentifier];
}

- (void)setModelsData:(NSMutableArray<PickerModel *> *)modelsArray {
    _pickerModels = modelsArray;
    [self fitPickerModelsData:_pickerModels toSections:_sectionsArray];
}

- (void)searchWithSearchString:(NSString *)searchString {
    if (searchString.length == 0) {
        _isSearching = false;
    } else {
        _isSearching = true;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.name contains[c] %@", searchString];
        _filteredPickerModels = (NSMutableArray*)[_pickerModels filteredArrayUsingPredicate:predicate];
        
        [self fitPickerModelsData:_filteredPickerModels toSections:_filteredSectionsArray];
    }
    
    [self reloadData];
}

- (NSMutableArray<NSMutableArray*>*)getValidSectionsArray {
    if (_isSearching)
        return _filteredSectionsArray;
    return _sectionsArray;
}

- (int)getSelectedCount {
    return _selectedCount;
}

- (void)reloadData {
    [_tableView reloadData];
}

- (void)fitPickerModelsData:(NSMutableArray<PickerModel*> *)models toSections:(NSMutableArray<NSMutableArray*> *)sectionsArray {
    for (int i = 0; i < models.count; i++) {
        [sectionsArray[i] removeAllObjects];
    }
    
    if (!models or models.count == 0)
        return;
    
    for (int i = 0; i < models.count; i++) {
        int index = [models[i] getSectionIndex];
        
        if (index >= 0 and index < ALPHABET_SECTIONS_NUMBER - 1) {
            [sectionsArray[index] addObject:models[i]];
        } else {
            [sectionsArray[ALPHABET_SECTIONS_NUMBER - 1] addObject:models[i]];
        }
    }
}

#pragma mark - UITableViewDelegateProtocol

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray<NSMutableArray*> *data = [self getValidSectionsArray];
    
    PickerTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    PickerModel *pickerModel = data[indexPath.section][indexPath.row];
    
    if (pickerModel.isChosen) {
        _selectedCount--;
        [_delegate uncheckCellAtIndexPath:indexPath];
    } else if (_selectedCount < 5) {
        _selectedCount++;
        [_delegate checkedCellAtIndexPath:indexPath];
    } else
        return;
    
    pickerModel.isChosen = !pickerModel.isChosen;
    [cell setChecked:pickerModel.isChosen];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor whiteColor];
}

// TODO: Hide section header if this is empty section
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView.dataSource tableView:tableView numberOfRowsInSection:section] == 0) {
        return 0;
    } else {
        return SECTION_HEADER_HEIGHT;
    }
}


#pragma mark - UITableViewDataSourceProtocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return ALPHABET_SECTIONS_NUMBER;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    char sectionNameChar = section + FIRST_ALPHABET_ASCII_CODE;
    
    if (section == ALPHABET_SECTIONS_NUMBER - 1)
        return @"#";
    
    return [NSString stringWithFormat:@"%c", sectionNameChar].uppercaseString;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray<NSMutableArray*> *data = [self getValidSectionsArray];
    
    if (data.count == 0)
        return 0;
    
    if (data[section])
        return data[section].count;
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PickerTableViewCell *cell = (PickerTableViewCell*)[tableView dequeueReusableCellWithIdentifier:PickerTableViewCell.reuseIdentifier];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:PickerTableViewCell.nibName owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSMutableArray<NSMutableArray*> *data = [self getValidSectionsArray];
    
    PickerModel *pickerModel = data[indexPath.section][indexPath.row];
    if (!pickerModel)
        return nil;
    
    [cell setName:pickerModel.name];
    [cell setChecked:pickerModel.isChosen];
    
    if (_delegate)
        [cell setAvatar:[_delegate getImageForCell:cell atIndexPath:indexPath]];
    
    if (indexPath.row == data[indexPath.section].count - 1)
        [cell showSeparatorLine:true];
    else
        [cell showSeparatorLine:false];
    
    return cell;
}


@end