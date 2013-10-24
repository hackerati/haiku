//
//  main.m
//  PoemData
//
//  Created by Greg Karlin on 9/25/13.
//  Copyright (c) 2013 Greg Karlin. All rights reserved.
//

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
        } else {
            NSLog(@"Saving generated db to %@", url.path);
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
        newPoem.edition = edition;
        newPoem.isFavorite = NO;
        newPoem.publishDate = [[poem valueForKey:@"published"] valueForKey:@"$t"];
        newPoem.poemId = [[poem valueForKey:@"id"] valueForKey:@"$t"];

        // Add share urls to the poem
        NSArray *links = [poem valueForKey:@"link"];
        for (NSDictionary *link in links) {
            NSString *type = [link valueForKey:@"rel"];
            if ([type  isEqual: @"alternate"]) {
                newPoem.shareUrl = [link valueForKey:@"href"];
                continue;
            }
            newPoem.shareUrl = newPoem.title;
        }
        
        //Save images locally and replace source references
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\"(https?://[0-9]+\.bp\.blogspot\.com/(?:[a-zA-Z0-9\-_]+/)+)([^\"]*)\"" options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray *matches = [regex matchesInString:newPoem.content
                                          options:0
                                            range:NSMakeRange(0, [newPoem.content length])];
        
        for (NSTextCheckingResult *match in matches) {
            NSRange matchRange = [match range];
            //url path
            NSRange firstHalfRange = [match rangeAtIndex:1];
            //filename
            NSRange secondHalfRange = [match rangeAtIndex:2];
            
            if ([[newPoem.content substringWithRange:firstHalfRange] rangeOfString:@"-h"].location == NSNotFound) {
            
                //file paths on system
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[newPoem.content substringWithRange:secondHalfRange]];
                
                //store image if it doesn't exist
                if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                    NSString *urlstr = [NSString stringWithFormat:@"%@%@", [newPoem.content substringWithRange:firstHalfRange], [newPoem.content substringWithRange:secondHalfRange]];
                    NSURL *url = [NSURL URLWithString:urlstr];
                    NSData *imageData = [NSData dataWithContentsOfURL:url];
                    [[NSFileManager defaultManager] createFileAtPath:filePath contents:imageData attributes:nil];
                }
            }
        }

        newPoem.content = [regex stringByReplacingMatchesInString:newPoem.content
                                                                   options:0
                                                                     range:NSMakeRange(0, [newPoem.content length])
                                                              withTemplate:@"\"images/$2\""];
        
        // Correct any empty fields.
        if ([newPoem.title length] == 0) {
            NSUInteger strlen = [newPoem.content length] - 1;
            NSUInteger idx = (strlen > 30) ? 30 : strlen;
            newPoem.title = [newPoem.content substringToIndex:idx];
        }
        
        // Add categories to HKPoem
        NSArray *categories = [poem valueForKey:@"category"];
        
        for (NSJSONSerialization * category in categories)
        {
            NSString *categoryTerm = [category valueForKey:@"term"];
            HKCategory *newCategory = [NSEntityDescription insertNewObjectForEntityForName:@"HKCategory" inManagedObjectContext:context];
            
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
    return 0;
}
