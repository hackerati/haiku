//
//  HKInitialViewController.h
//  haiku
//
//  Created by Kevin Tulod on 10/5/13.
//  Copyright (c) 2013 The Hackerati. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKBaseViewController.h"

enum HKPageId {
    HKAllPoemsPage = 0,
    HKHomePage = 1,
    HKFavePoemsPage = 2
    };

@interface HKInitialViewController : HKBaseViewController <UIScrollViewDelegate>

- (void)didSelectPoem:(HKPoem *)poem;

@end
