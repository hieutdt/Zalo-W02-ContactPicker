//
//  ContactAdaper.m
//  Zalo-W02-Contact Picker
//
//  Created by Trần Đình Tôn Hiếu on 3/11/20.
//  Copyright © 2020 Trần Đình Tôn Hiếu. All rights reserved.
//

#import "ContactAdaper.h"
#import "StringHelper.h"
#import "AppConsts.h"

#import <Contacts/Contacts.h>

@interface ContactAdaper()

@property (nonatomic, strong) NSMutableArray<Contact*> *contacts;
@property (nonatomic, strong) NSCache<NSString *, NSData *> *imagesDataCache;

@end


static ContactAdaper *staticInstance;

@implementation ContactAdaper

- (instancetype)init {
    self = [super init];
    if (self) {
        self.imagesDataCache = [[NSCache alloc] init];
        self.imagesDataCache.countLimit = MAX_IMAGES_CACHE_SIZE;
        self.contacts = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (instancetype)instance {
    if (!staticInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            staticInstance = [[ContactAdaper alloc] init];
        });
    }
    return staticInstance;
}

- (void)fetchContactsWithCompletion:(void (^)(NSError * error))completionHandle {
    dispatch_queue_t concurrentQueue = dispatch_queue_create("fetch_contact_queue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(concurrentQueue, ^{
        NSMutableArray<CNContact*> *contacts = [[NSMutableArray alloc] init];
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        
        auto *fullNameKey = [CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName];
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[fullNameKey, CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey]];
        
        try {
            [contactStore enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
                [contacts addObject:contact];
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Caching here
                [self saveCNContactsToContactsArray:contacts];
                completionHandle(nil);
            });
        } catch (NSException *e) {
            NSLog(@"Unable to fetch contacts");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableDictionary* details = [NSMutableDictionary dictionary];
                [details setValue:@"Unable to fetch contacts" forKey:NSLocalizedDescriptionKey];
                
                NSError *error = [[NSError alloc] initWithDomain:@"ContactAdapter" code:200 userInfo:details];
                
                completionHandle(error);
            });
        }
    });
}

- (void)fetchContactImageDataByID:(NSString *)contactID completion:(void (^)(NSError * error))completionHandle {
    NSPredicate *predicate = [CNContact predicateForContactsWithIdentifiers:@[contactID]];
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    NSError *error = [[NSError alloc] initWithDomain:@"ContactAdapter" code:200 userInfo:@{@"Fetch image failed": NSLocalizedDescriptionKey}];
    
    dispatch_queue_t concurrentQueue = dispatch_queue_create("ConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(concurrentQueue, ^{
        try {
            NSArray<CNContact*> *contacts = [contactStore unifiedContactsMatchingPredicate:predicate keysToFetch:@[CNContactThumbnailImageDataKey] error:nil];
            
            if (contacts.count == 0) {
                completionHandle(error);
                return;
            }
            
            // Cache this image data
            [self.imagesDataCache setObject:contacts[0].thumbnailImageData forKey:contacts[0].identifier];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandle(nil);
            });
            
        } catch (NSException *e) {
            NSLog(@"Fetch image failed!");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandle(error);
            });
        }
    });
}

- (NSMutableArray<Contact *> *)getContactsList {
    return self.contacts;
}

- (NSData*)getImageDataOfContactWithID:(NSString *)contactID {
    return [self.imagesDataCache objectForKey:contactID];
}

- (void)saveCNContactsToContactsArray:(NSMutableArray<CNContact*> *)CNContacts {
    for (CNContact *cnContact in CNContacts) {
        Contact *contact = [[Contact alloc] init];
        contact.identifier = cnContact.identifier;
        contact.name = [[NSString alloc] initWithFormat:@"%@ %@", cnContact.givenName, cnContact.familyName];
        contact.name = [StringHelper standardizeString:contact.name];
        
        if (cnContact.phoneNumbers.count > 0)
            contact.phoneNumber = [cnContact.phoneNumbers objectAtIndex:0].value.stringValue;
        else
            contact.phoneNumber = @"";
        
        contact.isChosen = false;
        
        [self.contacts addObject:contact];
    }
}

@end
