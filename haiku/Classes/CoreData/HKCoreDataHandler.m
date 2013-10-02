//
//  HKCoreDataHandler.m
//  haiku
//
//  Created by Kevin Tulod on 10/1/13.
//  Copyright (c) 2013 The Hackerati. All rights reserved.
//

#import "HKCoreDataHandler.h"
#import "HKPoem.h"
#import "HKCategory.h"

static NSManagedObjectModel *managedObjectModel()
{
    static NSManagedObjectModel *model = nil;
    if (model != nil) {
        return model;
    }
    
    NSString *path = @"HKPoemDataModel";
    path = [path stringByDeletingPathExtension];
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:path withExtension:@"momd"];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return model;
}

static NSManagedObjectContext *managedObjectContext()
{
    static NSManagedObjectContext *context = nil;
    if (context != nil) {
        return context;
    }
    
    @autoreleasepool {
        context = [[NSManagedObjectContext alloc] init];
        
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel()];
        [context setPersistentStoreCoordinator:coordinator];
        
        NSString *path = [[NSProcessInfo processInfo] arguments][0];
        path = [path stringByDeletingPathExtension];
        NSURL *url = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"sqlite"]];
        
        NSError *error;
        NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error];
        
        if (newStore == nil) {
            NSLog(@"Store Configuration Failure %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        }
    }
    return context;
}

int *addPoemDataToContext(NSJSONSerialization *poemData, NSManagedObjectContext *context, NSString *edition)
{
    NSJSONSerialization *feed = [poemData valueForKey:@"feed"];
    NSArray *allPoems = [feed valueForKey:@"entry"];
    
    for (NSJSONSerialization * poem in allPoems)
    {
        HKPoem *newPoem = [NSEntityDescription insertNewObjectForEntityForName:@"HKPoem" inManagedObjectContext:context];
        
        newPoem.title = [[poem valueForKey:@"title"] valueForKey:@"$t"];
        newPoem.content = [[poem valueForKey:@"content"] valueForKey:@"$t"];
        
        NSArray *categories = [poem valueForKey:@"category"];
        
        for (NSJSONSerialization * category in categories)
        {
            NSString *categoryTerm = [category valueForKey:@"term"];
            HKCategory *newCategory = [NSEntityDescription insertNewObjectForEntityForName:@"HKCategory" inManagedObjectContext:context];
            
            newCategory.name = categoryTerm;
            newPoem.category = newCategory;
            newPoem.edition = edition;
        }
    }
    return 0;
}

void createDataStore()
{
    @autoreleasepool {
        NSManagedObjectContext *context = managedObjectContext();
        NSError* err = nil;
        NSArray *poemSrc = [NSArray arrayWithObjects:@"us", @"jp", @"sp", nil];
        
        for (NSString *editionSrc in poemSrc) {
            NSString* dataPath = [[NSBundle mainBundle] pathForResource:editionSrc ofType:@"json"];
            NSJSONSerialization* poemData = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]
                                                                            options:kNilOptions
                                                                              error:&err];
            addPoemDataToContext(poemData, context, editionSrc);
        }
        // Save the managed object context
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error while saving %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
            exit(1);
        }
    }
}

@interface HKCoreDataHandler()

@property NSManagedObjectContext *poemDataContext;

@end

@implementation HKCoreDataHandler

+ (void)initializeDataStore
{
    // Check if the sqlite database has been created. If not, create it.
    NSString *path = [[NSProcessInfo processInfo] arguments][0];
    path = [path stringByDeletingPathExtension];
    NSURL *dbURL = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"sqlite"]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[dbURL path]]) {
        createDataStore();
    }
}

#pragma mark - Singleton methods
+ (id)sharedManager {
    static HKCoreDataHandler *cdhMgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cdhMgr = [[self alloc] init];
    });
    return cdhMgr;
}

- (id)init {
    if (self = [super init]) {
        self.poemDataContext = managedObjectContext();
        self.allPoems = [self getAllPoems];
        self.favoritePoems = [self getAllPoems];
    }
    return self;
}

- (NSArray *)getAllPoems
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"HKPoem" inManagedObjectContext:self.poemDataContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError *error;
    NSArray *results = [self.poemDataContext executeFetchRequest:request error:&error];
    
    return results;
}


@end
