//
//  MainViewController.m
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/11/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "MainViewController.h"
#import "PickerView.h"
#import "Contact.h"

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet PickerView *contactPickerView;

@property (strong, nonatomic) NSMutableArray<Contact*> *contacts;
@property (strong, nonatomic) NSMutableArray<NSMutableArray*> *data;

@property (strong, nonatomic) NSMutableArray<Contact*> *filteredContacts;
@property (strong, nonatomic) NSMutableArray<NSMutableArray*> *filteredData;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

@end
