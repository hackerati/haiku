//
//  HKCategory.h
//  PoemData
//
//  Created by Greg Karlin on 9/25/13.
//  Copyright (c) 2013 Greg Karlin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface HKCategory : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSManagedObject *poem;

@end
