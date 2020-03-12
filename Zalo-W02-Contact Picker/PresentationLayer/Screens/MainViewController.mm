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

@interface MainViewController () <PickerViewDelegate, PickerTableViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet PickerTableView *tableView;
@property (weak, nonatomic) IBOutlet PickerView *contactPickerView;

@property (strong, nonatomic) NSMutableArray<Contact *> *contacts;
@property (strong, nonatomic) NSMutableArray<NSMutableArray *> *sectionData;

@property (strong, nonatomic) NSMutableArray<Contact *> *filteredContacts;
@property (strong, nonatomic) NSMutableArray<NSMutableArray *> *filteredSectionData;

@property (strong, nonatomic) NSMutableArray<PickerModel *> *pickerModels;

@end


@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.delegate = self;
    _contactPickerView.delegate = self;
    
    _contacts = [[NSMutableArray alloc] init];
    _sectionData = [[NSMutableArray alloc] init];
    
    _filteredContacts = [[NSMutableArray alloc] init];
    _filteredSectionData = [[NSMutableArray alloc] init];
    
    _pickerModels = [[NSMutableArray alloc] init];
    
    CNAuthorizationStatus authorizationStatus = [[ContactBusiness instance] checkPermissionToAccessContactData];
    switch (authorizationStatus) {
        case CNAuthorizationStatusAuthorized: {
            [self loadContacts];
            break;
        }
        case CNAuthorizationStatusDenied | CNAuthorizationStatusNotDetermined:
            [self showNotPermissionView];
            break;
            
        default:
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

- (void)loadContacts {
    //TODO: show loading here
    
    [[ContactBusiness instance] fetchContactsWithCompletion:^(NSMutableArray<Contact *> *contacts, NSError *error) {
        //TODO: Hide loading here
        
        if (!error) {
            self.contacts = contacts;
            self.pickerModels = [self getPickerModelsArrayFromContacts];
            [self.tableView setModelsData:self.pickerModels];
            [self.tableView reloadData];
        } else {
            [self showErrorView];
        }
    }];
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
        pickerModel.name = contact.name;
        pickerModel.isChosen = false;
        pickerModel.imageData = nil;
        
        [pickerModels addObject:pickerModel];
    }
    
    return pickerModels;
}

#pragma mark - PickerViewDelegateProtocol


#pragma mark - PickerTableViewDelegateProtocol

- (UIImage*)getImageForCell:(PickerTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    return nil;
}

- (void)uncheckCellAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row < _pickerModels.count)
        [_contactPickerView removeElement:_pickerModels[indexPath.row]];
}

- (void)checkedCellAtIndexPath:(NSIndexPath*)indexPath {
    if (indexPath.row < _pickerModels.count)
        [_contactPickerView addElement:_pickerModels[indexPath.row]];
}


@end
