//
//  CIBorderedButton.m
//  CMOA
//
//  Created by Ruben Niculcea on 2/8/16.
//  Copyright © 2016 Carnegie Museums. All rights reserved.
//

#import "CIBorderedButton.h"

@implementation CIBorderedButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.borderColor = [UIColor colorFromHex:kCIWhiteTextColor];
        self.borderHighligthedColor = [UIColor colorFromHex:kCIAccentColor];
        [self loadStyles];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.borderColor = [UIColor colorFromHex:kCIWhiteTextColor];
        self.borderHighligthedColor = [UIColor colorFromHex:kCIAccentColor];
        [self loadStyles];
    }
    return self;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    [self loadStyles];
}

- (void)setBorderHighlightedColor:(UIColor *)borderHighlightedColor {
    _borderHighligthedColor = borderHighlightedColor;
}

- (void)loadStyles {
    self.layer.borderColor = self.borderColor.CGColor;
    self.layer.borderWidth = 1;
    self.layer.masksToBounds = true;
    self.layer.cornerRadius = 5;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.layer.borderColor = self.borderHighligthedColor.CGColor;
    } else {
        self.layer.borderColor = self.borderColor.CGColor;
    }
}

@end
