//
//  HKInitialViewController.m
//  haiku
//
//  Created by Kevin Tulod on 10/5/13.
//  Copyright (c) 2013 The Hackerati. All rights reserved.
//

#import "HKInitialViewController.h"

#import "HKHomeViewController.h"
#import "HKAllPoemsViewController.h"
#import "HKFavoritePoemsViewController.h"

@interface HKInitialViewController ()

@property IBOutlet UIScrollView *paginatedView;
@property IBOutlet UISegmentedControl *pageSelector;

@property HKHomeViewController *homeViewController;
@property HKAllPoemsViewController *allPoemsViewController;
@property HKFavoritePoemsViewController *favePoemsViewController;

@end

@implementation HKInitialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.homeViewController = [[HKHomeViewController alloc] initWithMainView:self];
    self.allPoemsViewController = [[HKAllPoemsViewController alloc] initWithMainView:self];
    self.favePoemsViewController = [[HKFavoritePoemsViewController alloc] initWithMainView:self];
    
    [self initPaginatedView];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Default to home page on start.
    [self moveToPage:HKHomePage];
    [self.pageSelector setSelectedSegmentIndex:HKHomePage];
}

- (void)initPaginatedView
{
    NSArray *subviews = @[self.allPoemsViewController.view,
                          self.homeViewController.view,
                          self.favePoemsViewController.view];
    int nSubviews = [subviews count];
    
    CGRect frame = self.paginatedView.frame;
    [self.paginatedView setContentSize:CGSizeMake(frame.size.width*nSubviews, frame.size.height)];
    [self.paginatedView setPagingEnabled:YES];
    
    // Correct the frames of the subviews and add to the paginated scroll view.
    for (int sIdx = 0; sIdx < nSubviews; sIdx++) {
        UIView *subview = subviews[sIdx];

        CGRect sFrame = subview.frame;
        sFrame.origin.x = frame.size.width*sIdx;
        sFrame.origin.y = frame.origin.y;
        sFrame.size.height = frame.size.height;
        subview.frame = sFrame;
        
        [self.paginatedView addSubview:subview];
    }
}

- (IBAction)pageSelectorChanged:(id)sender
{
    int page = self.pageSelector.selectedSegmentIndex;
    if (page == HKFavePoemsPage) {
        [self.favePoemsViewController reloadTable];
    }
    
    [self moveToPage:page];
}

- (void)moveToPage:(int)page
{
    // Programmatically move to the next page.
    CGRect frame = self.paginatedView.frame;
    frame.origin.x = frame.size.width*page;
    frame.origin.y = 0;
    [self.paginatedView scrollRectToVisible:frame animated:YES];
}

- (void)didSwipeToPage:(int)page
{
    if (page == HKFavePoemsPage) {
        [self.favePoemsViewController reloadTable];
    }
    [self.pageSelector setSelectedSegmentIndex:page];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    static NSInteger previousPage = 0;
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    if (previousPage != page) {
        previousPage = page;
        [self didSwipeToPage:page];
    }
}

- (void)didSelectPoem:(HKPoem *)poem
{
    [self.homeViewController loadPoem:poem];
    
    [self.pageSelector setSelectedSegmentIndex:HKHomePage];
    [self moveToPage:HKHomePage];
}

@end
