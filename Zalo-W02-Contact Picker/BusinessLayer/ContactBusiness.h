//
//  ContactBusiness.h
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/11/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Contacts/Contacts.h>
#import "Contact.h"
#import "AppConsts.h"

#import "ContactDidChangedDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactBusiness : NSObject

+ (ContactAuthorState)permissionStateToAccessContactData;

+ (void)requestAccessWithCompletionHandle:(void (^)(BOOL granted))completionHandle;

+ (void)loadContactsWithCompletion:(void (^)(NSMutableArray<Contact *> *contacts, NSError *error))completionHandle;

+ (void)reloadContactsWithCompletion:(void (^)(NSMutableArray<Contact *> *contacts, NSError *error))completionHandle;

+ (void)loadContactImageByID:(NSString*)contactID completion:(void (^)(UIImage *image, NSError *error))completionHandle;

+ (NSMutableArray<NSMutableArray *> *)sortedByAlphabetSectionsArrayFromContacts:(NSMutableArray<Contact *> *)contacts;

+ (void)fitContactsData:(NSMutableArray<Contact *> *)contacts toSectionArray:(NSMutableArray<NSMutableArray *> *)sections;

+ (void)resigterContactDidChangedDelegate:(id<ContactDidChangedDelegate>)delegate;

+ (void)removeContactDidChangedDelegate:(id<ContactDidChangedDelegate>)delegate;

+ (BOOL)contactsDataOutUpdated;

+ (void)checkAppDataOutUpdatedWhenInitWithCompletion:(void (^)(BOOL outUpdated))completionHandle;

@end

NS_ASSUME_NONNULL_END
