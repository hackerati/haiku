//
//  HKPoemWebView.m
//  haiku
//
//  Created by Kevin Tulod on 9/14/13.
//  Copyright (c) 2013 The Hackerati. All rights reserved.
//

#import "HKPoemWebView.h"
#import "HKPoem.h"

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

- (void)loadPoem:(HKPoem *)poem {
    // Temporary load method.

    NSString *htmlTemplate = [[NSBundle mainBundle] pathForResource:@"iphone_tmpl" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:htmlTemplate
                                               encoding:NSUTF8StringEncoding error:nil];

    html = [html stringByReplacingOccurrencesOfString:@"{{title}}" withString:poem.title];
    html = [html stringByReplacingOccurrencesOfString:@"{{content}}" withString:poem.content];

    [self setPoemHtmlString:html];

    [self loadHTMLString:self.poemHtmlString baseURL:[[NSBundle mainBundle] resourceURL]];
}

@end
