//
//  HKCoreDataHandler.h
//  haiku
//
//  Created by Kevin Tulod on 10/1/13.
//  Copyright (c) 2013 The Hackerati. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKCoreDataHandler : NSObject

+ (id)sharedManager;

- (NSArray *)getAllPoems;
- (NSArray *)getAllPoemsByEdition:(NSString *)editionId;
- (NSArray *)getFavoritePoems;
- (NSArray *)getFavoritePoemsForEdition:(NSString *)editionId;

@property NSArray *allPoems;
@property NSArray *favoritePoems;

@end
