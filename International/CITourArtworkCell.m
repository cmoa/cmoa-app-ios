//
//  CITourArtworkCell.m
//  International
//
//  Created by Dimitry Bentsionov on 8/1/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CITourArtworkCell.h"

#define kInsetTop 11
#define kInsetBottom 13
#define kInsetLeft 15
#define kInsetRight 15
#define kLabelSpace 7
#define kSequenceLabelSize 30

@implementation CITourArtworkCell

- (void)configureCell {
    // Sequence lbl
    self.sequenceLabel = [[UILabel alloc] init];
    self.sequenceLabel.backgroundColor = [UIColor colorFromHex:kCIAccentColor];
    self.sequenceLabel.textColor = [UIColor whiteColor];
    self.sequenceLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
    self.sequenceLabel.textAlignment = NSTextAlignmentCenter;
    self.sequenceLabel.layer.cornerRadius = kSequenceLabelSize / 2.0f;
    self.sequenceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.sequenceLabel clipsToBounds];

    // Add child
    [self.contentView addSubview:self.sequenceLabel];
    
    // Super configuration
    [super configureCell];
}

- (void)updateConstraints {
    if (self.constraintsUpdated == NO) {
        // Set label constraints
        NSDictionary *views = @{
                                @"title" : self.titleLabel,
                                @"subtitle" : self.subtitleLabel,
                                @"sequence" : self.sequenceLabel
                                };
        NSArray *horizontalCon1 = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(%i)-[sequence]-(%i)-[title]-(%i)-|", kInsetLeft, kInsetLeft, kInsetRight]
                                                                          options:0
                                                                          metrics:nil
                                                                            views:views];
        NSArray *horizontalCon2 = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(%i)-[sequence(%i)]-(%i)-[subtitle]-(%i)-|", kInsetLeft, kSequenceLabelSize, kInsetLeft, kInsetRight]
                                                                          options:0
                                                                          metrics:nil
                                                                            views:views];
        NSArray *verticalCon1 = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(%i)-[title]-(%i)-[subtitle]-(%i)-|", kInsetTop, kLabelSpace, kInsetBottom]
                                                                        options:0
                                                                        metrics:nil
                                                                          views:views];
        NSLayoutConstraint *verticalCon2 = [NSLayoutConstraint constraintWithItem:self.sequenceLabel
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.contentView
                                                                        attribute:NSLayoutAttributeTop
                                                                       multiplier:1.0f
                                                                         constant:kInsetTop];
        NSLayoutConstraint *heightCon1 = [NSLayoutConstraint constraintWithItem:self.sequenceLabel
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:0
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1.0f
                                                                       constant:kSequenceLabelSize];

        [self.contentView addConstraints:horizontalCon1];
        [self.contentView addConstraints:horizontalCon2];
        [self.contentView addConstraints:verticalCon1];
        [self.contentView addConstraint:verticalCon2];
        [self.sequenceLabel addConstraint:heightCon1];
        self.constraintsUpdated = YES;
    }
    
    // Set default constraints
    [super updateConstraints];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Keep sequence lbl steady
    self.sequenceLabel.backgroundColor = [UIColor colorFromHex:kCIAccentColor];
    self.sequenceLabel.textColor = [UIColor whiteColor];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];

    // Keep sequence lbl steady
    self.sequenceLabel.backgroundColor = [UIColor colorFromHex:kCIAccentColor];
    self.sequenceLabel.textColor = [UIColor whiteColor];
}

@end