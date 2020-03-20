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
@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, strong) dispatch_queue_t concurrentQueue;
@property (nonatomic, strong) NSMutableArray<id<ContactDidChangedDelegate>> *contactDidChangedDelegates;

@end

@implementation ContactAdaper

- (instancetype)init {
    self = [super init];
    if (self) {
        _contacts = [[NSMutableArray alloc] init];
        _serialQueue = dispatch_queue_create("contactAdaperSerialQueue", DISPATCH_QUEUE_SERIAL);
        _concurrentQueue = dispatch_queue_create("contactAdapterConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);
        _contactDidChangedDelegates = [[NSMutableArray alloc] init];
        
        // Add Contact changes Observer
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactsDidChange) name:CNContactStoreDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)instance {
    static id sharedInstance = nil;
    
    if (!sharedInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedInstance = [[ContactAdaper alloc] init];
        });
    }
    
    return sharedInstance;
}

- (void)contactsDidChange {
    NSLog(@"TONHIEU: contact did changed!");
    
    [self refetchContactsWithCompletion:^(NSMutableArray<Contact *> *contacts, NSError *error) {
        if (error)
            return;
        
        for (int i = 0; i < self.contactDidChangedDelegates.count; i++) {
            id<ContactDidChangedDelegate> delegate = [self.contactDidChangedDelegates objectAtIndex:i];
            if (delegate and [delegate respondsToSelector:@selector(contactsDidChanged)]) {
                [delegate contactsDidChanged];
            }
        }
    }];
}

- (BOOL)hasContactsData {
    return self.contacts and self.contacts.count > 0;
}

- (void)fetchContactsWithCompletion:(void (^)(NSMutableArray<Contact *> *contacts, NSError * error))completionHandle {
    if (!completionHandle)
        return;
    
    if ([self hasContactsData]) {
        completionHandle(self.contacts, nil);
        return;
    }
    
    dispatch_async(self.serialQueue, ^{
        if ([self hasContactsData]) {
            completionHandle(self.contacts, nil);
            return;
        }
        
        NSMutableArray<CNContact*> *contacts = [[NSMutableArray alloc] init];
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        
        auto *fullNameKey = [CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName];
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[fullNameKey, CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey]];
        
        try {
            [contactStore enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact *contact, BOOL *stop) {
                [contacts addObject:contact];
            }];
            
            // Caching here
            [self saveCNContactsToContactsArray:contacts];
            completionHandle(self.contacts, nil);
            
        } catch (NSException *e) {
            NSLog(@"Unable to fetch contacts: %@", e);
            
            NSMutableDictionary *details = [NSMutableDictionary dictionary];
            [details setValue:@"Lấy dữ liệu danh bạ thất bại." forKey:NSLocalizedDescriptionKey];
            NSError *error = [[NSError alloc] initWithDomain:@"ContactAdapter" code:200 userInfo:details];
            completionHandle(nil, error);
        }
    });
}

- (void)refetchContactsWithCompletion:(void (^)(NSMutableArray<Contact *> *contacts, NSError *error))completionHandle {
    if (!completionHandle)
        return;
    
    dispatch_async(self.serialQueue, ^{
        NSMutableArray<CNContact*> *contacts = [[NSMutableArray alloc] init];
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        
        auto *fullNameKey = [CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName];
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[fullNameKey, CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey]];
        
        try {
            [contactStore enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact *contact, BOOL *stop) {
                [contacts addObject:contact];
            }];
            
            // Caching here
            [self saveCNContactsToContactsArray:contacts];
            completionHandle(self.contacts, nil);
            
        } catch (NSException *e) {
            NSLog(@"Unable to fetch contacts: %@", e);
            
            NSMutableDictionary *details = [NSMutableDictionary dictionary];
            [details setValue:@"Lấy dữ liệu danh bạ thất bại." forKey:NSLocalizedDescriptionKey];
            NSError *error = [[NSError alloc] initWithDomain:@"ContactAdapter" code:200 userInfo:details];
            completionHandle(nil, error);
        }
    });
}

- (void)fetchContactImageDataByID:(NSString *)contactID completion:(void (^)(UIImage *image, NSError *error))completionHandle {
    if (!completionHandle)
        return;
    
    NSPredicate *predicate = [CNContact predicateForContactsWithIdentifiers:@[contactID]];
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    NSError *error = [[NSError alloc] initWithDomain:@"ContactAdapter" code:200 userInfo:@{@"Tải hình ảnh thất bại.": NSLocalizedDescriptionKey}];
    
    dispatch_async(self.concurrentQueue, ^{
        try {
            NSArray<CNContact*> *contacts = [contactStore unifiedContactsMatchingPredicate:predicate keysToFetch:@[CNContactThumbnailImageDataKey] error:nil];
            
            if (contacts.count == 0) {
                completionHandle(nil, error);
                return;
            }
            
            UIImage *image = [UIImage imageWithData:contacts[0].thumbnailImageData];
            completionHandle(image, nil);
            
        } catch (NSException *e) {
            NSLog(@"Load image failed: %@", e);
            completionHandle(nil, error);
        }
    });
}

- (void)saveCNContactsToContactsArray:(NSMutableArray<CNContact*> *)CNContacts {
    @synchronized (self) {
        [self.contacts removeAllObjects];
        
        for (CNContact *cnContact in CNContacts) {
            Contact *contact = [[Contact alloc] init];
            contact.identifier = cnContact.identifier;
            contact.name = [[NSString alloc] initWithFormat:@"%@ %@", cnContact.givenName, cnContact.familyName];
            contact.name = [StringHelper standardizeString:contact.name];
            
            if (cnContact.phoneNumbers.count > 0)
                contact.phoneNumber = [cnContact.phoneNumbers objectAtIndex:0].value.stringValue;
            else
                contact.phoneNumber = @"";
            
            [self.contacts addObject:contact];
        }
    }
}

- (CNAuthorizationStatus)getAccessContactAuthorizationStatus {
    return [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
}

- (void)requestAccessWithCompletionHandle:(void (^)(BOOL granted))completionHandle {
    if (!completionHandle)
        return;
    
    [[[CNContactStore alloc] init] requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError *error) {
        if (error or !granted) {
            completionHandle(false);
        } else {
            completionHandle(true);
        }
    }];
}

- (void)resigterContactDidChangedDelegate:(id<ContactDidChangedDelegate>)delegate {
    if (!delegate)
        return;
    
    // Avoid run one task more times
    if ([self.contactDidChangedDelegates containsObject:delegate])
        return;

    @synchronized (self) {
        [self.contactDidChangedDelegates addObject:delegate];
    }
}

- (void)removeContactDidChangedDelegate:(id<ContactDidChangedDelegate>)delegate {
    if (!delegate)
        return;
    
    @synchronized (self) {
        [self.contactDidChangedDelegates removeObject:delegate];
    }
}

@end
