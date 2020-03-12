//
//  ContactAdaper.h
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/11/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Contact.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactAdaper : NSObject

+ (instancetype)instance;

- (void)fetchContactsWithCompletion:(void (^)(NSError *error))completionHandle;
- (void)fetchContactImageDataByID:(NSString*)contactID completion:(void (^)(NSError *error))completionHandle;

- (NSMutableArray<Contact*> *)getContactsList;
- (NSData*)getImageDataOfContactWithID:(NSString*)contactID;

@end

NS_ASSUME_NONNULL_END
