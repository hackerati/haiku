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

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        // Create the managed object context
        NSManagedObjectContext *context = managedObjectContext();
        
        
        NSError* err = nil;
        NSString* dataPath = [[NSBundle mainBundle] pathForResource:@"poems" ofType:@"json"];
        NSJSONSerialization* all_poem_data = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:dataPath]
                                                         options:kNilOptions
                                                           error:&err];
        NSJSONSerialization * feed = [all_poem_data valueForKey:@"feed"];
        NSArray * all_poems = [feed valueForKey:@"entry"];
        
        for (NSJSONSerialization * poem in all_poems)
        {
            Poem * new_poem = [NSEntityDescription insertNewObjectForEntityForName:@"Poem" inManagedObjectContext:context];
            
            new_poem.title = [[poem valueForKey:@"title"] valueForKey:@"$t"];
            new_poem.content = [[poem valueForKey:@"content"] valueForKey:@"$t"];

            NSArray * categories = [poem valueForKey:@"category"];
            
            for (NSJSONSerialization * category in categories)
            {
                NSString * category_term = [category valueForKey:@"term"];
                Category * new_category = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:context];

                new_category.name = category_term;
                new_poem.category = new_category;
            }
            
            
        }
        
        
        
        
        

        
        
        // Custom code here...
        // Save the managed object context
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Error while saving %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
            exit(1);
        }
    }
    return 0;
}

