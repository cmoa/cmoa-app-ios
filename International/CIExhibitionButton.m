//
//  CIExhibitionButton.m
//  International
//
//  Created by Dimitry Bentsionov on 7/23/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIExhibitionButton.h"

@implementation CIExhibitionButton

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
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 15.0f, 0.0f, 15.0f);
    [self setTitleColor:[UIColor colorFromHex:@"#2e2e2e"] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor colorFromHex:@"#2e2e2e" alpha:0.7f] forState:UIControlStateHighlighted];
    
    // Sep line (on the bottom)
    sepView = [[UIView alloc] initWithFrame:(CGRect){{0.0f, self.frame.size.height - 0.5f}, {self.frame.size.width, 0.5f}}];
    sepView.backgroundColor = [UIColor colorFromHex:@"#a7a7a7"];
    sepView.userInteractionEnabled = NO;
    [self addSubview:sepView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Set sep line position
    sepView.frame = (CGRect){{0.0f, self.frame.size.height - 0.5f}, {self.frame.size.width, 0.5f}};
}

@end