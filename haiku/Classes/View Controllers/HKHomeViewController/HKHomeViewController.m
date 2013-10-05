//
//  HKHomeViewController.m
//  haiku
//
//  Created by Kevin Tulod on 9/14/13.
//  Copyright (c) 2013 The Hackerati. All rights reserved.
//

#import "HKHomeViewController.h"
#import "HKAllPoemsViewController.h"
#import "SWRevealViewController.h"
#import "HKPoemWebView.h"


@interface HKHomeViewController ()
{
}

@property IBOutlet HKPoemWebView *poemWebView;
@property IBOutlet UIBarButtonItem *revealAllButtonItem;
@property IBOutlet UIBarButtonItem *revealFavesButtonItem;

@end

@implementation HKHomeViewController

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
    [self.revealAllButtonItem setTarget:self.revealViewController];
    [self.revealAllButtonItem setAction:@selector(revealToggle:)];
    [self.revealFavesButtonItem setTarget:self.revealViewController];
    [self.revealFavesButtonItem setAction:@selector(rightRevealToggle:)];
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

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
    [self.poemWebView loadPoem:self.poemData.allPoems[randIdx]];
}

- (IBAction)refreshPoem:(id)sender
{
    [self loadRandomPoem];
}

- (IBAction) share: (id) sender {
    NSString* someText = @"SHMARGUM";// self.textView.text;
    NSArray* dataToShare = @[someText];  // ...or whatever pieces of data you want to share.
    
    UIActivityViewController* activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                      applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:^{}];
}

@end
