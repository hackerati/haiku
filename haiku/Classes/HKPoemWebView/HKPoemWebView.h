//
//  HKPoemWebView.h
//  haiku
//
//  Created by Kevin Tulod on 9/14/13.
//  Copyright (c) 2013 The Hackerati. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HKPoem;

@interface HKPoemWebView : UIWebView
{
    
}

- (void)loadPoem:(HKPoem *)poem;

@end
