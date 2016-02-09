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

- (void) loadStyles {
    self.layer.borderColor = [UIColor colorFromHex:kCIWhiteTextColor].CGColor;
    self.layer.borderWidth = 1;
    self.layer.masksToBounds = true;
    self.layer.cornerRadius = 5;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.layer.borderColor = [UIColor colorFromHex:kCIAccentColor].CGColor;
    } else {
        self.layer.borderColor = [UIColor colorFromHex:kCIWhiteTextColor].CGColor;
    }
}

@end
