//
//  HKHomeViewController.m
//  haiku
//
//  Created by Kevin Tulod on 9/14/13.
//  Copyright (c) 2013 The Hackerati. All rights reserved.
//

#import "HKHomeViewController.h"
#import "HKAllPoemsViewController.h"
#import "HKInitialViewController.h"
#import "SWRevealViewController.h"
#import "HKPoemWebView.h"
#import "HKPoem.h"


@interface HKHomeViewController ()
{
    IBOutlet UIBarButtonItem *toggleFaveButtonItem;
}

@property IBOutlet HKPoemWebView *poemWebView;
@property IBOutlet UIBarButtonItem *revealAllButtonItem;
@property IBOutlet UIBarButtonItem *revealFavesButtonItem;

@property HKInitialViewController *mainViewController;

@end

@implementation HKHomeViewController

- (id)initWithMainView:(HKInitialViewController *)mainView
{
    self = [super initWithNibName:@"HKHomeViewController_iPhone" bundle:nil];
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

    // Set SWRevealViewController Options
//    [self.revealAllButtonItem setTarget:self.revealViewController];
//    [self.revealAllButtonItem setAction:@selector(revealToggle:)];
//    [self.revealFavesButtonItem setTarget:self.revealViewController];
//    [self.revealFavesButtonItem setAction:@selector(rightRevealToggle:)];
//    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadRandomPoem];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadRandomPoem
{
    NSUInteger randIdx = arc4random() % [self.poemData.allPoems count];
    [self loadPoem:self.poemData.allPoems[randIdx]];
}

- (void)loadPoem:(HKPoem *)poem
{
    self.currentPoem = poem;
    // Set UI based on the current poem's properties
    if (self.currentPoem.isFavorite)
        [toggleFaveButtonItem setTitle:@"Unfave"];
    else
        [toggleFaveButtonItem setTitle:@"Fave"];
    
    // Load the poem
    [self.poemWebView loadPoem:self.currentPoem];
}

- (IBAction)refreshPoem:(id)sender
{
    [self loadRandomPoem];
}

- (IBAction) share: (id) sender {
    NSArray* dataToShare = @[self.currentPoem.shareUrl];  // ...or whatever pieces of data you want to share.
    
    UIActivityViewController* activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                      applicationActivities:nil];
    [self.mainViewController presentViewController:activityViewController animated:YES completion:^{}];
}

- (IBAction)toggleFavorite:(id)sender
{
    HKPoem *updatedPoem = [self.poemData togglePoemFavorite:self.currentPoem];
    if (updatedPoem != nil)
        [self loadPoem:updatedPoem];
}

@end
