//
//  SecondViewController.m
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/25/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "SecondViewController.h"
#import "ContactBusiness.h"
#import "ContactDidChangedDelegate.h"

@interface SecondViewController () <ContactDidChangedDelegate>

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    [ContactBusiness resigterContactDidChangedDelegate:self];
}


#pragma mark - ContactDidChangedDelegateProtocol

- (void)contactsDidChanged {
    self.view.backgroundColor = [UIColor blueColor];
}


@end
