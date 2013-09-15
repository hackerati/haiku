//
//  HKPoemWebView.m
//  haiku
//
//  Created by Kevin Tulod on 9/14/13.
//  Copyright (c) 2013 The Hackerati. All rights reserved.
//

#import "HKPoemWebView.h"

@interface HKPoemWebView()

@property NSString *poemHtmlString;

@end

@implementation HKPoemWebView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Haiku app custom functions

// TODO: Load a poem from a CoreData entity

- (void)loadNewPoem {
    // Temporary load method.

    NSString *htmlTemplate = [[NSBundle mainBundle] pathForResource:@"iphone_tmpl" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:htmlTemplate
                                               encoding:NSUTF8StringEncoding error:nil];

    [self setPoemHtmlString:html];

    [self loadHTMLString:self.poemHtmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
}

@end
