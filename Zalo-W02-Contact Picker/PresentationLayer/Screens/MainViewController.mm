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

#import "LayoutHelper.h"
#import "LoadingHelper.h"

#import "ImageCache.h"

#import "Contact.h"
#import "ContactBusiness.h"
#import "AppConsts.h"

#import "ContactDidChangedDelegate.h"

#import <JGProgressHUD/JGProgressHUD.h>

@interface MainViewController () <PickerViewDelegate, PickerTableViewDelegate, UISearchBarDelegate, ContactDidChangedDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet PickerTableView *tableView;
@property (weak, nonatomic) IBOutlet PickerView *contactPickerView;
@property (weak, nonatomic) IBOutlet UIStackView *contactStackView;

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *subTitleLabel;
@property (strong, nonatomic) UIBarButtonItem *cancelButtonItem;
@property (strong, nonatomic) UIBarButtonItem *updateButtonItem;

@property (strong, nonatomic) NSMutableArray<Contact *> *contacts;
@property (strong, nonatomic) NSMutableArray<NSMutableArray *> *sectionData;

@property (strong, nonatomic) NSMutableArray<PickerViewModel *> *pickerModels;

@property (strong, nonatomic) ErrorView *errorView;

@property (strong, nonatomic) ContactBusiness *contactBusiness;

@end


@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _contactBusiness = [[ContactBusiness alloc] init];
    
    _tableView.delegate = self;
    _tableView.layer.masksToBounds = NO;
    
    _contactPickerView.delegate = self;
    _contactPickerView.hidden = YES;
    _contactPickerView.layer.masksToBounds = NO;
    _contactPickerView.layer.shadowColor = [UIColor blackColor].CGColor;
    _contactPickerView.layer.shadowOpacity = 0.2;
    _contactPickerView.layer.shadowOffset = CGSizeZero;
    _contactPickerView.layer.shadowRadius = 2;
    
    _searchBar.delegate = self;
    
    _contacts = [[NSMutableArray alloc] init];
    _sectionData = [[NSMutableArray alloc] init];
    _pickerModels = [[NSMutableArray alloc] init];
    
    _errorView = [[ErrorView alloc] init];
    
    [self.contactBusiness resigterContactDidChangedDelegate:self];
    
    [self customInitNavigationBar];
    [self checkPermissionAndLoadContacts];
}

- (void)dealloc {
    [self.contactBusiness removeContactDidChangedDelegate:self];
}

- (void)checkPermissionAndLoadContacts {
    [self.errorView removeFromSuperview];
    
    ContactAuthorState authorizationState = [self.contactBusiness permissionStateToAccessContactData];
    switch (authorizationState) {
        case ContactAuthorStateAuthorized: {
            [self loadContacts];
            break;
        }
        case ContactAuthorStateDenied | ContactAuthorStateNotDetermined: {
            [self showNotPermissionView];
            break;
        }
        default: {
            [self.contactBusiness requestAccessWithCompletionHandle:^(BOOL granted) {
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
    [[LoadingHelper instance] showLoadingEffect];
    
    [self.contactBusiness loadContactsWithCompletion:^(NSMutableArray<Contact *> *contacts, NSError *error) {
        if (!error) {
            // Set up data will run in background
            self.contacts = contacts;
            
            if (self.contacts.count > 0) {
                [self initContactsData:contacts];
                [self setPickerModels:[self getPickerModelsArrayFromContacts]];
                [self.tableView setModelsData:self.pickerModels];
                
                // tableView.reloadData have to run after set up models data
                ASYNC_MAIN({
                    [[LoadingHelper instance] hideLoadingEffectDelay:1];
                    self.contactStackView.hidden = NO;
                    [self.tableView reloadData];
                });
            } else {
                ASYNC_MAIN({
                    [[LoadingHelper instance] hideLoadingEffectDelay:1];
                    [self showEmptyView];
                });
            }
        } else {
            ASYNC_MAIN({
                [[LoadingHelper instance] hideLoadingEffectDelay:1];
                [self showErrorViewWithErrorDescription:[error.userInfo valueForKey:NSLocalizedDescriptionKey]];
            });
        }
    }];
}

- (void)initContactsData:(NSMutableArray<Contact *> *)contacts {
    if (!contacts)
        return;
    
    self.contacts = contacts;
    self.sectionData = [self.contactBusiness sortedByAlphabetSectionsArrayFromContacts:self.contacts];
}

- (void)showEmptyView {
    self.contactStackView.hidden = YES;
    
    __weak MainViewController *weakSelf = self;
    [self.errorView setTilte:@"KHÔNG TÌM THẤY DỮ LIỆU" andDescription:@"Danh bạ của bạn đang trống! Vui lòng cập nhật danh bạ và thử lại sau!"];
    [self.errorView setImage:[UIImage imageNamed:@"no-data-found"]];
    [self.errorView setRetryButtonTitle:@"Thử lại"];
    [self.errorView setRetryBlock:^{
        ASYNC_MAIN({
            [weakSelf checkPermissionAndLoadContacts];
        });
    }];
    
    [self showSubView:self.errorView];
}

- (void)showNotPermissionView {
    self.contactStackView.hidden = YES;
    
    [self.errorView setTilte:@"TRUY CẬP BỊ TỪ CHỐI" andDescription:@"Bạn đã từ chối ứng dụng truy cập vào danh bạ. Vui lòng cấp quyền ở \"Cài đặt\" để tiếp tục sử dụng!"];
    [self.errorView setImage:[UIImage imageNamed:@"locked-icon"]];
    [self.errorView setRetryButtonTitle:@"Đến Cài đặt"];
    [self.errorView setRetryBlock:^{
        [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    }];
    
    [self showSubView:self.errorView];
}

- (void)showErrorViewWithErrorDescription:(NSString *)description {
    self.contactStackView.hidden = YES;
    
    __weak MainViewController *weakSelf = self;
    [self.errorView setImage:[UIImage imageNamed:@"fail-icon"]];
    
    if (description) {
        [self.errorView setTilte:@"THẤT BẠI" andDescription:[NSString stringWithFormat:@"%@ Vui lòng thử lại sau!", description]];
    } else {
        [self.errorView setTilte:@"THẤT BẠI" andDescription:@"Vui lòng thử lại sau!"];
    }
    [self.errorView setRetryButtonTitle:@"Thử lại"];
    [self.errorView setRetryBlock:^{
        ASYNC_MAIN({
            [weakSelf checkPermissionAndLoadContacts];
        });
    }];
    
    [self showSubView:self.errorView];
}

- (void)showSubView:(UIView *)view {
    if (!view)
        return;
    
    view.hidden = NO;
    
    [self.view addSubview:view];
    [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [view.topAnchor constraintEqualToAnchor:self.searchBar.bottomAnchor].active = YES;
    [view.leadingAnchor constraintEqualToAnchor:view.superview.leadingAnchor].active = YES;
    [view.trailingAnchor constraintEqualToAnchor:view.superview.trailingAnchor].active = YES;
    [view.bottomAnchor constraintEqualToAnchor:view.superview.bottomAnchor].active = YES;
    
    [self.view layoutIfNeeded];
}

- (NSMutableArray<PickerViewModel *> *)getPickerModelsArrayFromContacts {
    if (!self.contacts) {
        return nil;
    }
    
    NSMutableArray<PickerViewModel *> *pickerModels = [[NSMutableArray alloc] init];
    
    for (Contact *contact in self.contacts) {
        PickerViewModel *pickerModel = [[PickerViewModel alloc] init];
        pickerModel.identifier = contact.identifier;
        pickerModel.name = contact.name;
        pickerModel.isChosen = NO;
        
        [pickerModels addObject:pickerModel];
    }
    
    return pickerModels;
}

- (void)cancelPickContacts {
    [self.tableView removeAllElements];
    [self.contactPickerView removeAllElements];
    [self updateNavigationBar];
}

- (void)updateContactsTapped {
    [self hideUpdateContactNavigationButton];
    
    if (self.tableView.selectedCount > 0) {
        [self cancelPickContacts];
    }
    
    [self loadContacts];
}


#pragma mark - UISearchBarDelegateProtocol

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (!searchText)
        return;
    
    if (searchBar == self.searchBar) {
        [self.tableView searchWithSearchString:searchText];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar == self.searchBar) {
        [self.searchBar endEditing:YES];
    }
}


#pragma mark - PickerViewDelegateProtocol

- (void)pickerView:(UIView *)pickerView removeElement:(PickerViewModel *)pickerModel {
    if (!pickerModel)
        return;

    #if DEBUG
        assert(pickerModel);
    #endif
    
    if (pickerView == self.contactPickerView) {
        [self.tableView removeElement:pickerModel];
        [self updateNavigationBar];
    }
}

- (void)nextButtonTappedFromPickerView:(UIView *)pickerView {
    if (pickerView == self.contactPickerView) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Thông báo" message:@"Bạn đã ấn nút Tiếp tục" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


#pragma mark - PickerTableViewDelegateProtocol

- (void)pickerTableView:(UIView *)tableView loadImageToCell:(PickerTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    #if DEBUG
        assert(indexPath);
        assert(indexPath.section < self.sectionData.count);
        assert(indexPath.row < self.sectionData[indexPath.section].count);
    #endif
    
    if (tableView != self.tableView)
        return;
    if (!indexPath)
        return;
    if (indexPath.section >= self.sectionData.count)
        return;
    if (indexPath.row >= self.sectionData[indexPath.section].count)
        return;
    
    Contact *contact = (Contact *)self.sectionData[indexPath.section][indexPath.row];
    
    UIImage *imageFromCache = [[ImageCache instance] imageForKey:contact.identifier];
    if (imageFromCache) {
        [cell setAvatar:imageFromCache];
        [cell setNeedsLayout];
    } else {
        [self.contactBusiness loadContactImageByID:contact.identifier completion:^(UIImage *image, NSError *error) {
            ASYNC_MAIN({
                [[ImageCache instance] setImage:image forKey:contact.identifier];
                [cell setAvatar:image];
                [cell setNeedsLayout];
            });
        }];
    }
}

- (void)pickerTableView:(UIView *)tableView uncheckCellOfElement:(PickerViewModel *)element {
    #if DEBUG
        assert(element);
    #endif
    
    if (!element)
        return;
    
    if (tableView == self.tableView) {
        [self.contactPickerView removeElement:element];
        [self updateNavigationBar];
    }
}

- (void)pickerTableView:(UIView *)tableView checkedCellOfElement:(PickerViewModel *)element {
    #if DEBUG
        assert(element);
    #endif
    
    if (!element)
        return;
    
    if (tableView == self.tableView) {
        UIImage *imageFromCache = [[ImageCache instance] imageForKey:element.identifier];
        if (imageFromCache) {
            [self.contactPickerView addElement:element withImage:imageFromCache];
        } else {
            [self.contactBusiness loadContactImageByID:element.identifier completion:^(UIImage *image, NSError *error) {
                ASYNC_MAIN({
                    [[ImageCache instance] setImage:image forKey:element.identifier];
                    [self.contactPickerView addElement:element withImage:image];
                });
            }];
        }
        
        [self updateNavigationBar];
    }
}


#pragma mark - SetUpNavigationBar

- (void)customInitNavigationBar {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = @"Contacts list";
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleTitle3];
    self.titleLabel.textColor = [UIColor darkTextColor];
    
    self.subTitleLabel = [[UILabel alloc] init];
    self.subTitleLabel.text = @"Selected: 0/5";
    self.subTitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    self.subTitleLabel.textColor = [UIColor lightGrayColor];
    
    UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.titleLabel, self.subTitleLabel]];
    stackView.distribution = UIStackViewDistributionEqualCentering;
    stackView.alignment = UIStackViewAlignmentCenter;
    stackView.axis = UILayoutConstraintAxisVertical;
    
    self.navigationItem.titleView = stackView;
    
    self.cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelPickContacts)];
    self.cancelButtonItem.tintColor = [UIColor blackColor];
    
    self.updateButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Update" style:UIBarButtonItemStylePlain target:self action:@selector(updateContactsTapped)];
    self.updateButtonItem.tintColor = [UIColor blackColor];
    
    self.subTitleLabel.hidden = YES;
}

- (void)showCancelPickNavigationButton {
    [self.navigationItem setLeftBarButtonItem:self.cancelButtonItem animated:YES];
}

- (void)hideCancelPickNavigationButton {
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
}

- (void)showUpdateContactNavigationButton {
    [self.navigationItem setRightBarButtonItem:self.updateButtonItem animated:YES];
}

- (void)hideUpdateContactNavigationButton {
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
}

- (void)updateNavigationBar {
    if ([self.tableView selectedCount] > 0) {
        self.subTitleLabel.hidden = NO;
        [self showCancelPickNavigationButton];
    } else {
        self.subTitleLabel.hidden = YES;
        [self hideCancelPickNavigationButton];
    }
    
    self.subTitleLabel.text = [NSString stringWithFormat:@"Selected: %d/5", [self.tableView selectedCount]];
}


#pragma mark - ContactDidChangedDelegateProtocol

- (void)contactsDidChanged {
    ASYNC_MAIN({
        [self showUpdateContactNavigationButton];
    });
}

@end
