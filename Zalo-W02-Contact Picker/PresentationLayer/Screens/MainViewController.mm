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
#import "ErrorView.h"
#import "NoPermissionView.h"
#import "EmptyView.h"

#import "LayoutHelper.h"
#import "LoadingHelper.h"

#import "Contact.h"
#import "ContactBusiness.h"
#import "AppConsts.h"

#import <JGProgressHUD/JGProgressHUD.h>

@interface MainViewController () <PickerViewDelegate, PickerTableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet PickerTableView *tableView;
@property (weak, nonatomic) IBOutlet PickerView *contactPickerView;
@property (weak, nonatomic) IBOutlet UIStackView *contactStackView;

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *subTitleLabel;
@property (strong, nonatomic) UIBarButtonItem *cancelButtonItem;

@property (strong, nonatomic) NSMutableArray<Contact *> *contacts;
@property (strong, nonatomic) NSMutableArray<NSMutableArray *> *sectionData;

@property (strong, nonatomic) NSMutableArray<PickerModel *> *pickerModels;

@property (strong, nonatomic) ErrorView *errorView;
@property (strong, nonatomic) NoPermissionView *noPermissionView;
@property (strong, nonatomic) EmptyView *emptyView;

@end


@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.delegate = self;
    _tableView.layer.masksToBounds = false;
    
    _contactPickerView.delegate = self;
    _contactPickerView.hidden = true;
    _contactPickerView.layer.masksToBounds = false;
    _contactPickerView.layer.shadowColor = [UIColor blackColor].CGColor;
    _contactPickerView.layer.shadowOpacity = 0.2;
    _contactPickerView.layer.shadowOffset = CGSizeZero;
    _contactPickerView.layer.shadowRadius = 2;
    
    _searchBar.delegate = self;
    
    _contacts = [[NSMutableArray alloc] init];
    _sectionData = [[NSMutableArray alloc] init];
    _pickerModels = [[NSMutableArray alloc] init];
    
    _errorView = [[ErrorView alloc] init];
    _noPermissionView = [[NoPermissionView alloc] init];
    _emptyView = [[EmptyView alloc] init];
    
    for (int i = 0; i < ALPHABET_SECTIONS_NUMBER; i++) {
        _sectionData[i] = [[NSMutableArray alloc] init];
    }
    
    [self customInitNavigationBar];
    [self checkPermissionAndLoadContacts];
}

- (void)checkPermissionAndLoadContacts {
    [_errorView removeFromSuperview];
    [_noPermissionView removeFromSuperview];
    [_emptyView removeFromSuperview];
    
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) { // Access denied error sent here
                        [self showNotPermissionView];
                        return;
                    }
                    
                    if (granted) {
                        [self loadContacts];
                    } else {
                        [self showNotPermissionView];
                    }
                });
            }];
            break;
        }
    }
}

- (void)loadContacts {
    //TODO: show loading here
    [[LoadingHelper instance] showLoadingEffect];
    
    [[ContactBusiness instance] loadContactsWithCompletion:^(NSMutableArray<Contact *> *contacts, NSError *error) {
        //TODO: Hide loading here
        [[LoadingHelper instance] hideLoadingEffectDelay:1.5];
        
        if (!error) {
            self.contacts = contacts;
            
            if (self.contacts.count > 0) {
                self.contactStackView.hidden = false;
                
                [self initContactsData:contacts];
                self.pickerModels = [self getPickerModelsArrayFromContacts];
                
                [self.tableView setModelsData:self.pickerModels];
                [self.tableView reloadData];
            } else {
                [self showEmptyView];
            }
            
        } else {
            [self showErrorViewWithErrorDescription:[error.userInfo valueForKey:NSLocalizedDescriptionKey]];
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

- (void)showEmptyView {
    _contactStackView.hidden = true;
    
    __weak MainViewController *weakSelf = self;
    [_emptyView setTilte:@"KHÔNG TÌM THẤY DỮ LIỆU" andDescription:@"Danh bạ của bạn đang trống! Vui lòng cập nhật danh bạ và thử lại sau!"];
    [_emptyView setRetryBlock:^{
        [weakSelf checkPermissionAndLoadContacts];
    }];
    
    [self showSubView:_emptyView];
}

- (void)showNotPermissionView {
    _contactStackView.hidden = true;
    
    [_noPermissionView setTilte:@"TRUY CẬP BỊ TỪ CHỐI" andDescription:@"Bạn đã từ chối ứng dụng truy cập vào danh bạ. Vui lòng cấp quyền ở \"Cài đặt\" để tiếp tục sử dụng!"];
    [_noPermissionView setRetryBlock:^{
        [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    }];
    
    [self showSubView:_noPermissionView];
}

- (void)showErrorViewWithErrorDescription:(NSString *)description {
    _contactStackView.hidden = true;
    
    __weak MainViewController *weakSelf = self;
    [_errorView setTilte:@"THẤT BẠI" andDescription:[NSString stringWithFormat:@"%@ Vui lòng thử lại sau!", description]];
    [_errorView setRetryBlock:^{
        [weakSelf checkPermissionAndLoadContacts];
    }];
    
    [self showSubView:_errorView];
}

- (void)showSubView:(UIView *)view {
    view.hidden = false;
    
    [self.view addSubview:view];
    view.translatesAutoresizingMaskIntoConstraints = false;
    [view.topAnchor constraintEqualToAnchor:_searchBar.bottomAnchor].active = true;
    [view.leadingAnchor constraintEqualToAnchor:view.superview.leadingAnchor].active = true;
    [view.trailingAnchor constraintEqualToAnchor:view.superview.trailingAnchor].active = true;
    [view.bottomAnchor constraintEqualToAnchor:view.superview.bottomAnchor].active = true;
    
    [self.view layoutIfNeeded];
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

- (void)cancelPickContacts {
    [_tableView removeAllElements];
    [_contactPickerView removeAll];
    [self updateNavigationBar];
}

#pragma mark - UISearchBarDelegateProtocol

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [_tableView searchWithSearchString:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [_searchBar endEditing:true];
}


#pragma mark - PickerViewDelegateProtocol

- (void)removeElementFromPickerview:(PickerModel *)pickerModel {
    [_tableView removeElement:pickerModel];
    [self updateNavigationBar];
}

- (void)nextButtonTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Thông báo" message:@"Bạn đã ấn nút Tiếp tục" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:true completion:nil];
}

#pragma mark - PickerTableViewDelegateProtocol

- (void)loadImageToCell:(PickerTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Contact *contact = (Contact *)_sectionData[indexPath.section][indexPath.row];
    
    [[ContactBusiness instance] loadContactImageDataByID:contact.identifier completion:^(NSData *imageData, NSError *error) {
        [cell setAvatar:[UIImage imageWithData:imageData]];
        [cell setNeedsLayout];
    }];
}

- (void)uncheckCellOfElement:(PickerModel *)element {
    [_contactPickerView removeElement:element];
    [self updateNavigationBar];
}


- (void)checkedCellOfElement:(PickerModel *)element {
    [[ContactBusiness instance] loadContactImageDataByID:element.identifier completion:^(NSData *imageData, NSError *error) {
        [self.contactPickerView addElement:element withImageData:imageData];
    }];
    
    [self updateNavigationBar];
}

#pragma mark - SetUpNavigationBar

- (void)customInitNavigationBar {
    [self.navigationController setNavigationBarHidden:false animated:true];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"Contacts list";
    _titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
    _titleLabel.textColor = [UIColor darkTextColor];
    
    _subTitleLabel = [[UILabel alloc] init];
    _subTitleLabel.text = @"Selected: 0/5";
    _subTitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    _subTitleLabel.textColor = [UIColor lightGrayColor];
    
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[_titleLabel, _subTitleLabel]];
    stackView.distribution = UIStackViewDistributionEqualCentering;
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.axis = UILayoutConstraintAxisVertical;
    
    self.navigationItem.titleView = stackView;
    
    _cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelPickContacts)];
    _cancelButtonItem.tintColor = [UIColor blackColor];
    
    _subTitleLabel.hidden = true;
}

- (void)showCancelPickNavigationButton {
    self.navigationItem.leftBarButtonItem = _cancelButtonItem;
}

- (void)hideCancelPickNavigationButton {
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)updateNavigationBar {
    if ([_tableView selectedCount] > 0) {
        _subTitleLabel.hidden = false;
        [self showCancelPickNavigationButton];
    } else {
        _subTitleLabel.hidden = true;
        [self hideCancelPickNavigationButton];
    }
    
    _subTitleLabel.text = [NSString stringWithFormat:@"Selected: %d/5", [_tableView selectedCount]];
}


@end
