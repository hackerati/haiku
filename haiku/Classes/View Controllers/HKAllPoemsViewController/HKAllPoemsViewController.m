//
//  HKAllPoemsViewController.m
//  haiku
//
//  Created by Kevin Tulod on 9/14/13.
//  Copyright (c) 2013 The Hackerati. All rights reserved.
//

#import "HKAllPoemsViewController.h"
#import "HKInitialViewController.h"

@interface HKAllPoemsViewController ()

@property HKCoreDataHandler *poemData;
@property HKInitialViewController *mainViewController;

@end

@implementation HKAllPoemsViewController

- (id)initWithMainView:(HKInitialViewController *)mainView
{
    self = [super initWithNibName:@"HKAllPoemsViewController_iPhone" bundle:nil];
    if (self != nil){
        // Custom initialization
        self.mainViewController = mainView;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HKPoem *poem = self.poemData.allPoems[indexPath.row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"poemCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"poemCell"];
    }

    cell.textLabel.text = poem.title;
    cell.detailTextLabel.text = poem.publishDate;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.poemData.allPoems count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKPoem *poem = self.poemData.allPoems[indexPath.row];
    [self.mainViewController didSelectPoem:poem];
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
}

@end
