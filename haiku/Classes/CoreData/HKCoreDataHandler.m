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

        
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"PoemData.sqlite"];
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], NSReadOnlyPersistentStoreOption, nil];
        
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

#pragma mark - Initialization
+ (void)initializeDataStore
{
    NSString *appSupportDir = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
    if (![[NSFileManager defaultManager] fileExistsAtPath:appSupportDir isDirectory:NULL]) {
        NSError *error = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:appSupportDir withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"%@", error.localizedDescription);
        }
        
        NSString *staticDbPath = [[NSBundle mainBundle] pathForResource:@"PoemData" ofType:@"sqlite"];
        NSString *newDbPath = [appSupportDir stringByAppendingPathComponent:@"PoemData.sqlite"];
        
        [[NSFileManager defaultManager] copyItemAtPath:staticDbPath toPath:newDbPath error:&error];
        
    }
}

# pragma mark - Poem read requests.

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

#pragma mark - Poem write requests
- (HKPoem *)togglePoemFavorite:(HKPoem *)poem
{
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"HKPoem" inManagedObjectContext:self.poemDataContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"poemId=%@",poem.poemId]];
    
    NSError *error = nil;
    HKPoem *poemEntity = [[self.poemDataContext executeFetchRequest:request error:&error] lastObject];
    
    if (!poemEntity) {
        return nil;
    }
    
    // Switch the poem favorite and save it.
    poemEntity.isFavorite = !poem.isFavorite;
    error = nil;
    if (![self.poemDataContext save:&error]) {
        return nil;
    }
    
    // Update the favorites array.
    self.favoritePoems = [self getFavoritePoems];
    
    return poemEntity;
}

@end
