//
//  HKPoem.h
//  PoemData
//
//  Created by Greg Karlin on 9/25/13.
//  Copyright (c) 2013 Greg Karlin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HKCategory;

@interface HKPoem : NSManagedObject

@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *edition;
@property (nonatomic, retain) HKCategory *category;

@end