//
//  ContactBusiness.m
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/11/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "ContactBusiness.h"
#import "ContactAdaper.h"
#import "Contact.h"

#import <Contacts/Contacts.h>

@interface ContactBusiness ()

@property (strong, nonatomic) NSMutableArray<Contact*> *contacts;

@end

static ContactBusiness *sharedInstance = nil;

@implementation ContactBusiness

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

+ (instancetype)instance {
    if (!sharedInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[ContactBusiness alloc] init];
        });
    }
    
    return sharedInstance;
}

- (void)loadContactsWithCompletion:(void (^)(NSMutableArray<Contact *> * contacts, NSError * error))completionHandle {
    [[ContactAdaper instance] fetchContactsWithCompletion:^(NSError *error) {
        if (!error) {
            NSMutableArray<Contact*> *contactsData = [[ContactAdaper instance] getContactsList];
            completionHandle(contactsData, nil);
        } else {
            completionHandle(nil, error);
        }
    }];
}

- (void)loadContactImageDataByID:(NSString *)contactID completion:(void (^)(NSData * imageData, NSError * error))completionHandle {
    // Get image data from ContactAdaperCache
    __block NSData *imageData = [[ContactAdaper instance] getImageDataOfContactWithID:contactID];
    
    if (imageData) {
        completionHandle(imageData, nil);
        return;
    }
    
    [[ContactAdaper instance] fetchContactImageDataByID:contactID completion:^(NSError *error) {
        if (!error) {
            imageData = [[ContactAdaper instance] getImageDataOfContactWithID:contactID];
            completionHandle(imageData, nil);
        } else {
            completionHandle(nil, error);
        }
    }];
}

- (CNAuthorizationStatus)checkPermissionToAccessContactData {
    return [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
}

- (void)requestAccessWithCompletionHandle:(void (^)(BOOL granted, NSError *error))completionHandle {
    [[[CNContactStore alloc] init] requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        completionHandle(granted, error);
    }];
}

@end
