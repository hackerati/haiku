//
//  HKPoemsListViewController.h
//  haiku
//
//  Created by Kevin Tulod on 9/14/13.
//  Copyright (c) 2013 The Hackerati. All rights reserved.
//

#import "HKBaseViewController.h"

@class HKInitialViewController;

@interface HKPoemsListViewController : HKBaseViewController <UITableViewDelegate, UITableViewDataSource>

@property IBOutlet UITableView *poemTableView;

- (id)initWithMainView:(HKInitialViewController *)mainView;

@end
