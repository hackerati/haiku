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

#pragma mark - Managed Object Model functions

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

        NSURL *url = [[NSBundle mainBundle] URLForResource:@"PoemData" withExtension:@"sqlite"];
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSReadOnlyPersistentStoreOption, nil];
        
        NSError *error;
        NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&error];
        
        if (newStore == nil) {
            NSLog(@"Store Configuration Failure %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        }
    }
    return context;
}

#pragma mark - HKCoreDataHandler implementation

@interface HKCoreDataHandler()

@property NSManagedObjectContext *poemDataContext;

@end

@implementation HKCoreDataHandler

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
        self.favoritePoems = [self getFavoritePoems];
    }
    return self;
}

- (NSFetchRequest *)basePoemRequest
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"HKPoem" inManagedObjectContext:self.poemDataContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDateDesc = [[NSSortDescriptor alloc] initWithKey:@"publishDate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDateDesc, nil];
    [request setSortDescriptors:sortDescriptors];
    
    return request;
}

- (NSArray *)sendFetchRequest:(NSFetchRequest *)request
{
    NSError *error;
    NSArray *results = [self.poemDataContext executeFetchRequest:request error:&error];
    
    if (error != nil) {
        NSLog(@"Fetch error occurred with request: %@", request);
        return [[NSArray alloc] init];
    }
    
    return results;
}

- (NSArray *)getAllPoems
{
    NSFetchRequest *request = [self basePoemRequest];
    
    return [self sendFetchRequest:request];
}

- (NSArray *)getAllPoemsByEdition:(NSString *)editionId
{
    NSFetchRequest *request = [self basePoemRequest];
    
    NSPredicate *p = [NSPredicate predicateWithFormat:@"edition == %@", editionId];
    [request setPredicate:p];
    
    return [self sendFetchRequest:request];
}

- (NSArray *)getFavoritePoems
{
    NSFetchRequest *request = [self basePoemRequest];
    
    NSPredicate *p = [NSPredicate predicateWithFormat:@"isFavorite == 1"];
    [request setPredicate:p];
    
    return [self sendFetchRequest:request];
}

- (NSArray *)getFavoritePoemsForEdition:(NSString *)editionId
{
    NSFetchRequest *request = [self basePoemRequest];
    
    NSPredicate *p = [NSPredicate predicateWithFormat:@"isFavorite == 1 AND edition == %@", editionId];
    [request setPredicate:p];
    
    return [self sendFetchRequest:request];
}

@end
