//
//  CIWelcomeButton.m
//  International
//
//  Created by Dimitry Bentsionov on 7/22/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIWelcomeButton.h"

@implementation CIWelcomeButton

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
    // Background
    self.backgroundColor = [UIColor clearColor];
    
    // Font
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0f];
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 15.0f, 0.0f, 15.0f);
    [self setTitleColor:[UIColor colorFromHex:@"#ffffff"] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor colorFromHex:@"#ffffff" alpha:0.7f] forState:UIControlStateHighlighted];
    [self setBackgroundImage:[UIImage imageNamed:@"nav_welcome_bg"] forState:UIControlStateSelected];
    [self setTitleColor:[UIColor colorFromHex:@"#ffffff"] forState:UIControlStateSelected];
    
    // Sep line
    isSeparatorOnTop = YES;
    sepView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, {self.frame.size.width, 0.5f}}];
    sepView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    sepView.backgroundColor = [UIColor colorFromHex:@"#ffffff" alpha:0.2f];
    sepView.userInteractionEnabled = NO;
    [self addSubview:sepView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Set sep line position
    if (isSeparatorOnTop) {
        sepView.frame = (CGRect){CGPointZero, {self.frame.size.width, 0.5f}};
    } else {
        sepView.frame = (CGRect){{0.0f, self.frame.size.height - 0.5f}, {self.frame.size.width, 0.5f}};
    }
}

- (void)setSeparatorOnBottom {
    isSeparatorOnTop = NO;
    [self layoutSubviews];
}

@end