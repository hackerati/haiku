//
//  HKHomeViewController.h
//  haiku
//
//  Created by Kevin Tulod on 9/14/13.
//  Copyright (c) 2013 The Hackerati. All rights reserved.
//

#import "HKBaseViewController.h"

@class HKPoemWebView;
@class HKInitialViewController;

@interface HKHomeViewController : HKBaseViewController <UIScrollViewDelegate>

@property (nonatomic, strong) HKPoem *currentPoem;

- (id)initWithMainView:(HKInitialViewController *)mainView;
- (void)loadPoem:(HKPoem *)poem;

@end
