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
#import "AppDelegate.h"

#import <Contacts/Contacts.h>
#import <CoreData/CoreData.h>

@interface ContactAdaper()

@property (nonatomic, strong) NSMutableArray<Contact*> *contacts;
@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, strong) dispatch_queue_t concurrentQueue;
@property (nonatomic, strong) NSMutableArray<id<ContactDidChangedDelegate>> *contactDidChangedDelegates;
@property (nonatomic, strong) NSMutableArray<NSString *> *keysToFetch;
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic) BOOL dataOutUpdated;

@end

@implementation ContactAdaper

- (instancetype)init {
    self = [super init];
    if (self) {
        _contacts = [[NSMutableArray alloc] init];
        _serialQueue = dispatch_queue_create("contactAdaperSerialQueue", DISPATCH_QUEUE_SERIAL);
        _concurrentQueue = dispatch_queue_create("contactAdapterConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);
        _contactDidChangedDelegates = [[NSMutableArray alloc] init];
        
        auto *fullNameKey = [CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName];
        _keysToFetch = [NSMutableArray arrayWithArray:@[fullNameKey, CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey]];
        
        _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        _dataOutUpdated = NO;
        
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

- (BOOL)hasContactsData {
    return self.contacts and self.contacts.count > 0;
}

#pragma mark - CheckDataIsOutUpdated

- (BOOL)isDataOutUpdate {
    @synchronized (self) {
        BOOL dataUpdated = [[NSUserDefaults standardUserDefaults] valueForKey:@"dataUpdated"];
        return !dataUpdated;
    }
}

- (void)setDataUpdated:(BOOL)updated {
    @synchronized (self) {
        [[NSUserDefaults standardUserDefaults] setBool:updated forKey:@"dataUpdated"];
    }
}

#pragma mark - FetchMethods

- (void)fetchContactsWithCompletion:(void (^)(NSMutableArray<Contact *> *contacts, NSError * error))completionHandle {
    if (!completionHandle)
        return;
    
    dispatch_async(self.serialQueue, ^{
        if ([self hasContactsData]) {
            completionHandle(self.contacts, nil);
            return;
        }
        
        [self fetchContactsFromCoreData];
        
        if ([self hasContactsData]) {
            completionHandle(self.contacts, nil);
        } else {
            [self refetchContactsWithCompletion:completionHandle withSaveToCoreData:YES];
        }
    });
}

- (void)fetchContactsFromCoreData {
    NSManagedObjectContext *managedContext = [self.appDelegate.persistentContainer viewContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Person"];
    
    try {
        NSArray<NSManagedObject *> *contacts = [managedContext executeFetchRequest:fetchRequest error:nil];
        [self saveContactManagedObjectToContactsArray:contacts];
    } catch (NSError *err) {
        NSLog(@"Could not fetch: %@", err.userInfo);
    }
}

- (void)refetchFromPhoneContactsWithCompletion:(void (^)(NSMutableArray<Contact *> *contacts, NSError *error))completionHandle {
    dispatch_async(self.serialQueue, ^{
        [self refetchContactsWithCompletion:completionHandle withSaveToCoreData:YES];
    });
}

- (void)refetchContactsWithCompletion:(void (^)(NSMutableArray<Contact *> *contacts, NSError *error))completionHandle withSaveToCoreData:(BOOL)save {
    if (!completionHandle)
        return;
    
    NSMutableArray<CNContact*> *contacts = [[NSMutableArray alloc] init];
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:self.keysToFetch];
    
    try {
        [contactStore enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact *contact, BOOL *stop) {
            [contacts addObject:contact];
        }];
        
        [self saveCNContactsToContactsArray:contacts];
        if (save) {
            [self saveContactsDataToCoreData:self.contacts];
            [self setDataUpdated:YES];
        }
        
        completionHandle(self.contacts, nil);
        
    } catch (NSException *e) {
        NSLog(@"Unable to fetch contacts: %@", e);
        
        NSMutableDictionary *details = [NSMutableDictionary dictionary];
        [details setValue:@"Lấy dữ liệu danh bạ thất bại." forKey:NSLocalizedDescriptionKey];
        NSError *error = [[NSError alloc] initWithDomain:@"ContactAdapter" code:200 userInfo:details];
        completionHandle(nil, error);
    }
}

- (void)fetchContactImageDataByID:(NSString *)contactID completion:(void (^)(UIImage *image, NSError *error))completionHandle {
    if (!completionHandle)
        return;
    
    NSPredicate *predicate = [CNContact predicateForContactsWithIdentifiers:@[contactID]];
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    NSError *error = [[NSError alloc] initWithDomain:@"ContactAdapter" code:200 userInfo:@{@"Tải hình ảnh thất bại.": NSLocalizedDescriptionKey}];
    
    // Fetch multiple images concurrently
    dispatch_async(self.concurrentQueue, ^{
        try {
            NSArray<CNContact *> *contacts = [contactStore unifiedContactsMatchingPredicate:predicate keysToFetch:@[CNContactThumbnailImageDataKey] error:nil];
            
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


#pragma mark - AuthorizationStatusHandler

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

#pragma mark - SaveToContactEntityHandler

- (void)saveCNContactsToContactsArray:(NSMutableArray<CNContact*> *)CNContacts {
    @synchronized (self) {
        [self.contacts removeAllObjects];
        self.contacts = [self getContactModelsFromCNContacts:CNContacts];
    }
}

- (void)saveContactManagedObjectToContactsArray:(NSArray<NSManagedObject *> *)contacts {
    @synchronized (self) {
        [self.contacts removeAllObjects];
        for (int i = 0; i < contacts.count; i++) {
            Contact *contactModel = [[Contact alloc] init];
            contactModel.identifier = [contacts[i] valueForKey:@"identifier"];
            contactModel.name = [contacts[i] valueForKey:@"name"];
            contactModel.phoneNumber = [contacts[i] valueForKey:@"phoneNumber"];
            
            [self.contacts addObject:contactModel];
        }
    }
}

- (NSMutableArray<Contact *> *) getContactModelsFromCNContacts:(NSArray<CNContact *> *)CNContacts {
    NSMutableArray<Contact *> *contacts = [[NSMutableArray alloc] init];
    
    for (CNContact *cnContact in CNContacts) {
        Contact *contact = [[Contact alloc] init];
        contact.identifier = cnContact.identifier;
        contact.name = [[NSString alloc] initWithFormat:@"%@ %@", cnContact.givenName, cnContact.familyName];
        contact.name = [StringHelper standardizeString:contact.name];
        
        if (cnContact.phoneNumbers.count > 0)
            contact.phoneNumber = [cnContact.phoneNumbers objectAtIndex:0].value.stringValue;
        else
            contact.phoneNumber = @"";
        
        [contacts addObject:contact];
    }
    
    return contacts;
}

#pragma mark - ContactDidChangedDelegate

- (void)contactsDidChange {
    NSLog(@"TONHIEU: contact did changed!");
    
    [self setDataUpdated:NO];
    
    for (int i = 0; i < self.contactDidChangedDelegates.count; i++) {
        id<ContactDidChangedDelegate> delegate = [self.contactDidChangedDelegates objectAtIndex:i];
        if (delegate and [delegate respondsToSelector:@selector(contactsDidChanged)]) {
            [delegate contactsDidChanged];
        }
    }
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

- (void)checkDataOutUpdateWithComletion:(void (^)(BOOL outUpdated))completionHandle {
    dispatch_async(self.serialQueue, ^{
        NSMutableArray<CNContact*> *contacts = [[NSMutableArray alloc] init];
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:self.keysToFetch];
        
        try {
            [contactStore enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact *contact, BOOL *stop) {
                [contacts addObject:contact];
            }];
            
            if (contacts.count != self.contacts.count) {
                completionHandle(YES);
            }
            
            int i = 0;
            for (CNContact *cnContact in contacts) {
                Contact *contact = [[Contact alloc] init];
                contact.identifier = cnContact.identifier;
                contact.name = [[NSString alloc] initWithFormat:@"%@ %@", cnContact.givenName, cnContact.familyName];
                contact.name = [StringHelper standardizeString:contact.name];
                
                if (cnContact.phoneNumbers.count > 0)
                    contact.phoneNumber = [cnContact.phoneNumbers objectAtIndex:0].value.stringValue;
                else
                    contact.phoneNumber = @"";
                
                if (contact.i)
            }
            
        } catch (NSException *e) {
            
        }
        
    });
}

#pragma mark - CoreDataHandler

- (void)saveContactsDataToCoreData:(NSMutableArray<Contact *> *)contacts {
    if (!contacts)
        return;
    
    for (int i = 0; i < contacts.count; i++) {
        [self saveContactToCoreData:contacts[i]];
    }
}

- (void)saveContactToCoreData:(Contact *)contact {
    NSManagedObjectContext *managedContext =  [self.appDelegate.persistentContainer viewContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:managedContext];
    NSManagedObject *contactObject = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:managedContext];
    
    [contactObject setValue:contact.identifier forKey:@"identifier"];
    [contactObject setValue:contact.name forKey:@"name"];
    [contactObject setValue:contact.phoneNumber forKey:@"phoneNumber"];
    
    try {
        [managedContext save:nil];
    } catch (NSError *e) {
        NSLog(@"Could not save: %@", e.userInfo);
    }
}


@end
