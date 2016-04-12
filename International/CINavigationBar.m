//
//  CINavigationBar.m
//  International
//
//  Created by Dimitry Bentsionov on 7/22/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CINavigationBar.h"
#import "CINavigationItem.h"

#define BAR_BUTTON_SPACING 5.0f

@implementation CINavigationBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self loadStyles];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self loadStyles];
    }
    return self;
}

- (void)loadStyles {
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        [self setBackgroundImage:[UIImage imageNamed:@"nav_bg"] forBarMetrics:UIBarMetricsDefault];
        [self setShadowImage:[[UIImage alloc] init]];
    }
    
    [self setBarTintColor:[UIColor colorFromHex:kCIBarColor]];
    [self setTranslucent:NO];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Set bar button positioning (default different between iOS 6 & 7)
    CINavigationItem *item = (CINavigationItem *)self.topItem;
    if (item.leftBarButtonItem.customView != nil) {
        item.leftBarButtonItem.customView.frame = (CGRect){{BAR_BUTTON_SPACING, 0.0f}, item.leftBarButtonItem.customView.frame.size};
    }

    if (item.rightBarButtonItem.customView != nil) {
        CGFloat x = self.frame.size.width - item.rightBarButtonItem.customView.frame.size.width - BAR_BUTTON_SPACING;
        item.rightBarButtonItem.customView.frame = (CGRect){{x, 0.0f}, item.rightBarButtonItem.customView.frame.size};
    }
}

@end