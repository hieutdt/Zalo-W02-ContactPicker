//
//  ContactBusiness.h
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/11/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>
#import "Contact.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactBusiness : NSObject

+ (instancetype)instance;

- (CNAuthorizationStatus)checkPermissionToAccessContactData;
- (void)requestAccessWithCompletionHandle:(void (^)(BOOL granted, NSError *error))completionHandle;

- (void)loadContactsWithCompletion:(void (^)(NSMutableArray<Contact*> *contacts, NSError *error))completionHandle;
- (void)refetchContactsWithCompletion:(void (^)(NSMutableArray<Contact*> *contacts, NSError *error))completionHandle;

- (void)loadContactImageDataByID:(NSString*)contactID completion:(void (^)(NSData *imageData, NSError *error))completionHandle;

@end

NS_ASSUME_NONNULL_END
