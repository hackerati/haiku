//
//  HKBaseViewController.h
//  haiku
//
//  Created by Kevin Tulod on 9/14/13.
//  Copyright (c) 2013 The Hackerati. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKCoreDataHandler.h"
#import "HKPoem.h"

@interface HKBaseViewController : UIViewController

- (void) raiseExceptionForAbstractMethod;

@property HKCoreDataHandler *poemData;

@end
