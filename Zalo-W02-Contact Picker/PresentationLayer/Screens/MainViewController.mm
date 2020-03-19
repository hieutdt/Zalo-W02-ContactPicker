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
    
    [self customInitNavigationBar];
    [self checkPermissionAndLoadContacts];
}

- (void)checkPermissionAndLoadContacts {
    [self.errorView removeFromSuperview];
    [self.noPermissionView removeFromSuperview];
    [self.emptyView removeFromSuperview];
    
    ContactAuthorState authorizationState = [ContactBusiness permissionStateToAccessContactData];
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
            [ContactBusiness requestAccessWithCompletionHandle:^(BOOL granted) {
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
    [[LoadingHelper instance] showLoadingEffect];
    
    [ContactBusiness loadContactsWithCompletion:^(NSMutableArray<Contact *> *contacts, NSError *error) {
        ASYNC_MAIN({
            [[LoadingHelper instance] hideLoadingEffectDelay:1.5];
        });
        
        if (!error) {
            self.contacts = contacts;
            
            if (self.contacts.count > 0) {
                [self initContactsData:contacts];
                self.pickerModels = [self getPickerModelsArrayFromContacts];
                [self.tableView setModelsData:self.pickerModels];
                
                ASYNC_MAIN({
                    self.contactStackView.hidden = false;
                    [self.tableView reloadData];
                });
            } else {
                ASYNC_MAIN({
                    [self showEmptyView];
                });
            }
        } else {
            ASYNC_MAIN({
                [self showErrorViewWithErrorDescription:[error.userInfo valueForKey:NSLocalizedDescriptionKey]];
            });
        }
    }];
}

- (void)initContactsData:(NSMutableArray<Contact *> *)contacts {
    self.contacts = contacts;
    self.sectionData = [ContactBusiness sortedByAlphabetSectionsArrayFromContacts:self.contacts];
}

- (void)showEmptyView {
    self.contactStackView.hidden = true;
    
    __weak MainViewController *weakSelf = self;
    [self.emptyView setTilte:@"KHÔNG TÌM THẤY DỮ LIỆU" andDescription:@"Danh bạ của bạn đang trống! Vui lòng cập nhật danh bạ và thử lại sau!"];
    [self.emptyView setRetryBlock:^{
        [weakSelf checkPermissionAndLoadContacts];
    }];
    
    [self showSubView:self.emptyView];
}

- (void)showNotPermissionView {
    self.contactStackView.hidden = true;
    
    [self.noPermissionView setTilte:@"TRUY CẬP BỊ TỪ CHỐI" andDescription:@"Bạn đã từ chối ứng dụng truy cập vào danh bạ. Vui lòng cấp quyền ở \"Cài đặt\" để tiếp tục sử dụng!"];
    [self.noPermissionView setRetryBlock:^{
        [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    }];
    
    [self showSubView:self.noPermissionView];
}

- (void)showErrorViewWithErrorDescription:(NSString *)description {
    self.contactStackView.hidden = true;
    
    __weak MainViewController *weakSelf = self;
    [self.errorView setTilte:@"THẤT BẠI" andDescription:[NSString stringWithFormat:@"%@ Vui lòng thử lại sau!", description]];
    [self.errorView setRetryBlock:^{
        [weakSelf checkPermissionAndLoadContacts];
    }];
    
    [self showSubView:self.errorView];
}

- (void)showSubView:(UIView *)view {
    view.hidden = false;
    
    [self.view addSubview:view];
    view.translatesAutoresizingMaskIntoConstraints = false;
    [view.topAnchor constraintEqualToAnchor:self.searchBar.bottomAnchor].active = true;
    [view.leadingAnchor constraintEqualToAnchor:view.superview.leadingAnchor].active = true;
    [view.trailingAnchor constraintEqualToAnchor:view.superview.trailingAnchor].active = true;
    [view.bottomAnchor constraintEqualToAnchor:view.superview.bottomAnchor].active = true;
    
    [self.view layoutIfNeeded];
}

- (NSMutableArray<PickerModel *> *)getPickerModelsArrayFromContacts {
    if (!self.contacts) {
        return nil;
    }
    
    NSMutableArray<PickerModel *> *pickerModels = [[NSMutableArray alloc] init];
    
    for (Contact *contact in self.contacts) {
        PickerModel *pickerModel = [[PickerModel alloc] init];
        pickerModel.identifier = contact.identifier;
        pickerModel.name = contact.name;
        pickerModel.isChosen = false;
        
        [pickerModels addObject:pickerModel];
    }
    
    return pickerModels;
}

- (void)cancelPickContacts {
    [self.tableView removeAllElements];
    [self.contactPickerView removeAll];
    [self updateNavigationBar];
}

#pragma mark - UISearchBarDelegateProtocol

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.tableView searchWithSearchString:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar endEditing:true];
}


#pragma mark - PickerViewDelegateProtocol

- (void)removeElementFromPickerview:(PickerModel *)pickerModel {
    [self.tableView removeElement:pickerModel];
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
    Contact *contact = (Contact *)self.sectionData[indexPath.section][indexPath.row];
    
    [ContactBusiness loadContactImageByID:contact.identifier completion:^(UIImage *image, NSError *error) {
        ASYNC_MAIN({
            [cell setAvatar:image];
            [cell setNeedsLayout];
        });
    }];
}

- (void)uncheckCellOfElement:(PickerModel *)element {
    [self.contactPickerView removeElement:element];
    [self updateNavigationBar];
}


- (void)checkedCellOfElement:(PickerModel *)element {
    [ContactBusiness loadContactImageByID:element.identifier completion:^(UIImage *image, NSError *error) {
        ASYNC_MAIN({
            [self.contactPickerView addElement:element withImage:image];
        });
    }];
    
    [self updateNavigationBar];
}

#pragma mark - SetUpNavigationBar

- (void)customInitNavigationBar {
    [self.navigationController setNavigationBarHidden:false animated:true];
    
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
    
    self.subTitleLabel.hidden = true;
}

- (void)showCancelPickNavigationButton {
    self.navigationItem.leftBarButtonItem = self.cancelButtonItem;
}

- (void)hideCancelPickNavigationButton {
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)updateNavigationBar {
    if ([self.tableView selectedCount] > 0) {
        self.subTitleLabel.hidden = false;
        [self showCancelPickNavigationButton];
    } else {
        self.subTitleLabel.hidden = true;
        [self hideCancelPickNavigationButton];
    }
    
    self.subTitleLabel.text = [NSString stringWithFormat:@"Selected: %d/5", [self.tableView selectedCount]];
}


@end
