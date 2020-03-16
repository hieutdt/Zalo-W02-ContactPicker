//
//  MainViewController.m
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/11/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "MainViewController.h"
#import "PickerView.h"
#import "PickerTableView.h"
#import "Contact.h"
#import "ContactBusiness.h"
#import "AppConsts.h"

@interface MainViewController () <PickerViewDelegate, PickerTableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet PickerTableView *tableView;
@property (weak, nonatomic) IBOutlet PickerView *contactPickerView;

@property (strong, nonatomic) NSMutableArray<Contact *> *contacts;
@property (strong, nonatomic) NSMutableArray<NSMutableArray *> *sectionData;

@property (strong, nonatomic) NSMutableArray<PickerModel *> *pickerModels;

@end


@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.delegate = self;
    _tableView.layer.masksToBounds = false;
    
    _contactPickerView.delegate = self;
    _searchBar.delegate = self;
    
    _contacts = [[NSMutableArray alloc] init];
    _sectionData = [[NSMutableArray alloc] init];
    _pickerModels = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < ALPHABET_SECTIONS_NUMBER; i++) {
        _sectionData[i] = [[NSMutableArray alloc] init];
    }
    
    CNAuthorizationStatus authorizationStatus = [[ContactBusiness instance] checkPermissionToAccessContactData];
    switch (authorizationStatus) {
        case CNAuthorizationStatusAuthorized: {
            [self loadContacts];
            break;
        }
        case CNAuthorizationStatusDenied | CNAuthorizationStatusNotDetermined: {
            [self showNotPermissionView];
            break;
        }
        default: {
            [[ContactBusiness instance] requestAccessWithCompletionHandle:^(BOOL granted, NSError *error) {
                if (error) {
                    [self showErrorView];
                    return;
                }
                
                if (granted) {
                    [self loadContacts];
                } else {
                    [self showNotPermissionView];
                }
            }];
            break;
        }
    }
}

- (void)loadContacts {
    //TODO: show loading here
    
    [[ContactBusiness instance] fetchContactsWithCompletion:^(NSMutableArray<Contact *> *contacts, NSError *error) {
        //TODO: Hide loading here
        
        if (!error) {
            self.contacts = contacts;
            [self initContactsData:contacts];
            
            self.pickerModels = [self getPickerModelsArrayFromContacts];
            [self.tableView setModelsData:self.pickerModels];
            [self.tableView reloadData];
        } else {
            [self showErrorView];
        }
    }];
}

- (void)initContactsData:(NSMutableArray<Contact *> *)contacts {
    _contacts = contacts;
    [self fitContactsData:_contacts toSections:_sectionData];
}

- (void)fitContactsData:(NSMutableArray<Contact*> *)models toSections:(NSMutableArray<NSMutableArray*> *)sectionsArray {
    for (int i = 0; i < sectionsArray.count; i++) {
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

- (void)showNotPermissionView {
    
}

- (void)showErrorView {
    
}

- (NSMutableArray<PickerModel *> *)getPickerModelsArrayFromContacts {
    if (!_contacts) {
        return nil;
    }
    
    NSMutableArray<PickerModel *> *pickerModels = [[NSMutableArray alloc] init];
    
    for (Contact *contact in _contacts) {
        PickerModel *pickerModel = [[PickerModel alloc] init];
        pickerModel.identifier = contact.identifier;
        pickerModel.name = contact.name;
        pickerModel.isChosen = false;
        
        [pickerModels addObject:pickerModel];
    }
    
    return pickerModels;
}

#pragma mark - UISearchBarDelegateProtocol

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_tableView searchWithSearchString:searchText];
}


#pragma mark - PickerViewDelegateProtocol

- (void)removeElementFromPickerview:(PickerModel *)pickerModel {
    
}

- (void)nextButtonTapped {
    
}

#pragma mark - PickerTableViewDelegateProtocol

- (void)loadImageToCell:(PickerTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Contact *contact = (Contact *)_sectionData[indexPath.section][indexPath.row];
    
    [[ContactBusiness instance] fetchContactImageDataByID:contact.identifier completion:^(NSData *imageData, NSError *error) {
        [cell setAvatar:[UIImage imageWithData:imageData]];
        [cell setNeedsLayout];
    }];
}

- (void)uncheckCellOfElement:(PickerModel *)element {
    try {
        [_contactPickerView removeElement:element];
    } catch (NSException *e) {
        return;
    }
}


- (void)checkedCellOfElement:(PickerModel *)element withImageData:(NSData *)imageData {
    try {
        [_contactPickerView addElement:element withImageData:imageData];
    } catch (NSException *e) {
        return;
    }
}

@end
