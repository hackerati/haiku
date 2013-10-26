//
//  HKFavoritePoemsViewController.m
//  haiku
//
//  Created by Kevin Tulod on 9/14/13.
//  Copyright (c) 2013 The Hackerati. All rights reserved.
//

#import "HKFavoritePoemsViewController.h"
#import "HKInitialViewController.h"

@interface HKFavoritePoemsViewController ()

@property HKInitialViewController *mainViewController;

@end

@implementation HKFavoritePoemsViewController

- (id)initWithMainView:(HKInitialViewController *)mainView
{
    self = [super initWithNibName:@"HKFavoritePoemsViewController_iPhone" bundle:nil];
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

- (void)viewWillAppear:(BOOL)animated
{
    [self reloadTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadTable
{
    [self.poemTableView reloadData];
}

#pragma mark - UITableView Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HKPoem *poem = self.poemData.favoritePoems[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"poemCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"poemCell"];
    }
    
    UIFont *cellFont = [ UIFont fontWithName: @"Verdana" size: 14.0 ];
    
    cell.textLabel.text = poem.title;
    cell.textLabel.font = cellFont;
    cell.textLabel.textAlignment = NSTextAlignmentRight;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKPoem *poem = self.poemData.favoritePoems[indexPath.row];
    [self.mainViewController didSelectPoem:poem];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.poemData.favoritePoems count];
}

@end
