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

@interface ContactBusiness()

@property (strong, nonatomic) NSMutableArray<Contact*> *contacts;

@end

static ContactBusiness *staticInstance;

@implementation ContactBusiness

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

+ (instancetype)instance {
    if (!staticInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            staticInstance = [[ContactBusiness alloc] init];
        });
    }
    
    return staticInstance;
}

- (void)fetchContactsWithCompletion:(void (^)(NSMutableArray<Contact *> * contacts, NSError * error))completionHandle {
    [[ContactAdaper instance] fetchContactsWithCompletion:^(NSError * _Nonnull error) {
        if (!error) {
            NSMutableArray<Contact*> *contactsData = [[ContactAdaper instance] getContactsList];
            completionHandle(contactsData, nil);
        } else {
            completionHandle(nil, error);
        }
    }];
}

- (void)fetchContactImageDataByID:(NSString *)contactID completion:(void (^)(NSData * imageData, NSError * error))completionHandle {
    
}

- (void)checkPermissionToAccessContactDataWithCompletion:(void (^)(NSError * _Nonnull))completionHandle {
    
}

@end
