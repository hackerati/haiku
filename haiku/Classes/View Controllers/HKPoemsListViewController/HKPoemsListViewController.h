//
//  HKPoemsListViewController.h
//  haiku
//
//  Created by Kevin Tulod on 9/14/13.
//  Copyright (c) 2013 The Hackerati. All rights reserved.
//

#import "HKBaseViewController.h"

@interface HKPoemsListViewController : HKBaseViewController <UITableViewDelegate, UITableViewDataSource>

@property IBOutlet UITableView *poemTableView;

@end
