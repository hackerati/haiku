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
    UIButton *toggleFaveButtonItem;
    IBOutlet UIToolbar *toolbar;
    CGPoint initialTitleOrigin;
}

@property IBOutlet HKPoemWebView *poemWebView;
@property IBOutlet UIBarButtonItem *revealAllButtonItem;
@property IBOutlet UIBarButtonItem *revealFavesButtonItem;
@property IBOutlet UILabel *titleLabel;

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
    [self.poemWebView setBackgroundColor:[UIColor clearColor]];
    [self.poemWebView setOpaque:NO];
    [self.poemWebView.scrollView setDelegate:self];
    initialTitleOrigin = self.titleLabel.frame.origin;
    
    toggleFaveButtonItem =  [UIButton buttonWithType:UIButtonTypeCustom];
    [toggleFaveButtonItem setImage:[UIImage imageNamed:@"images/star-inactive.png"] forState:UIControlStateNormal];
    [toggleFaveButtonItem setImage:[UIImage imageNamed:@"images/star-active.png"] forState:UIControlStateSelected];
    [toggleFaveButtonItem addTarget:self action:@selector(toggleFavorite:) forControlEvents:UIControlEventTouchUpInside];
    [toggleFaveButtonItem setFrame:CGRectMake(0, 0, 28, 28)];
    NSMutableArray *newItems = [toolbar.items mutableCopy];
    [newItems addObject:[[UIBarButtonItem alloc] initWithCustomView:toggleFaveButtonItem]];
    toolbar.items = newItems;
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
    self.titleLabel.text = self.currentPoem.title;
    // Set UI based on the current poem's properties
    if (self.currentPoem.isFavorite) {
        [toggleFaveButtonItem setSelected:YES];
    } else {
        [toggleFaveButtonItem setSelected:NO];
    }
    
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect titleFrame = self.titleLabel.frame;
    titleFrame.origin.y = -(scrollView.contentOffset.y / 3) + initialTitleOrigin.y;
    self.titleLabel.frame = titleFrame;
}

@end
