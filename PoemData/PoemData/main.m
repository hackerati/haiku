//
//  main.m
//  PoemData
//
//  Created by Greg Karlin on 9/25/13.
//  Copyright (c) 2013 Greg Karlin. All rights reserved.
//

#import "Poem.h"
#import "Category.h"


static NSManagedObjectModel *managedObjectModel()
{
    static NSManagedObjectModel *model = nil;
    if (model != nil) {
        return model;
    }
    
    NSString *path = @"PoemData";
    path = [path stringByDeletingPathExtension];
    NSURL *modelURL = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"momd"]];
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
        
        NSString *STORE_TYPE = NSSQLiteStoreType;
        
        NSString *path = [[NSProcessInfo processInfo] arguments][0];
        path = [path stringByDeletingPathExtension];
        NSURL *url = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"sqlite"]];
        
        NSError *error;
        NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:nil error:&error];
        
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
        Poem *newPoem = [NSEntityDescription insertNewObjectForEntityForName:@"Poem" inManagedObjectContext:context];
        
        newPoem.title = [[poem valueForKey:@"title"] valueForKey:@"$t"];
        newPoem.content = [[poem valueForKey:@"content"] valueForKey:@"$t"];
        
        NSArray *categories = [poem valueForKey:@"category"];
        
        for (NSJSONSerialization * category in categories)
        {
            NSString *categoryTerm = [category valueForKey:@"term"];
            Category *newCategory = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];
            
            newCategory.name = categoryTerm;
            newPoem.category = newCategory;
        }
    }
    return 0;
}

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        NSManagedObjectContext *context = managedObjectContext();
        NSError* err = nil;
        NSArray *poemSrc = [NSArray arrayWithObjects:@"matsushita-us", @"matsushita-jp", @"matsushita-sp", nil];
        
        for (NSString *editionSrc in poemSrc) {
            NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"matsushita-us" ofType:@"json"];
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
    return 0;
}
