//
//  CIHoursCell.m
//  International
//
//  Created by Dimitry Bentsionov on 8/6/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIHoursCell.h"

@implementation CIHoursCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)configureCell {
    // Default background
    cellBackgroundColor = [UIColor colorFromHex:@"#ffffff"];

    // Status lbls
    self.statusLabelTop = [[UILabel alloc] init];
    self.statusLabelTop.textColor = [UIColor colorFromHex:@"#ffffff"];
    self.statusLabelTop.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
    self.statusLabelTop.translatesAutoresizingMaskIntoConstraints = NO;

    self.statusLabelBottom = [[UILabel alloc] init];
    self.statusLabelBottom.textColor = [UIColor colorFromHex:@"#ffffff"];
    self.statusLabelBottom.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11.0f];
    self.statusLabelBottom.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Add children
    [self addSubview:self.statusLabelTop];
    [self addSubview:self.statusLabelBottom];

    // Super configuration
    [super configureCell];
}

- (void)setCellAsHours {
    UIColor *hoursColor = [UIColor colorFromHex:@"#f2f2f2"];
    cellBackgroundColor = hoursColor;
    self.contentView.backgroundColor = hoursColor;
    self.titleLabel.backgroundColor = hoursColor;
    self.subtitleLabel.backgroundColor = hoursColor;
    self.statusLabelTop.backgroundColor = hoursColor;
    self.statusLabelBottom.backgroundColor = hoursColor;
}

- (void)setTodayAsOpen:(BOOL)open {
    self.titleLabel.textColor = [UIColor colorFromHex:@"#ffffff"];
    self.subtitleLabel.textColor = [UIColor colorFromHex:@"#ffffff"];

    if (open) {
        cellBackgroundColor = [UIColor colorFromHex:@"#98cf8b"];
        self.contentView.backgroundColor = [UIColor colorFromHex:@"#98cf8b"];
        self.titleLabel.backgroundColor = [UIColor colorFromHex:@"#98cf8b"];
        self.subtitleLabel.backgroundColor = [UIColor colorFromHex:@"#98cf8b"];
        self.statusLabelTop.text = @"The museum is";
        self.statusLabelTop.backgroundColor = [UIColor colorFromHex:@"#98cf8b"];
        self.statusLabelBottom.text = @"NOW OPEN";
        self.statusLabelBottom.backgroundColor = [UIColor colorFromHex:@"#98cf8b"];
    } else {
        cellBackgroundColor = [UIColor colorFromHex:@"#f26361"];
        self.contentView.backgroundColor = [UIColor colorFromHex:@"#f26361"];
        self.titleLabel.backgroundColor = [UIColor colorFromHex:@"#f26361"];
        self.subtitleLabel.backgroundColor = [UIColor colorFromHex:@"#f26361"];
        self.statusLabelTop.text = @"The museum is";
        self.statusLabelTop.backgroundColor = [UIColor colorFromHex:@"#f26361"];
        self.statusLabelBottom.text = @"NOW CLOSED";
        self.statusLabelBottom.backgroundColor = [UIColor colorFromHex:@"#f26361"];
    }
    
    // Position status label
    [self.statusLabelTop sizeToFit];
    [self.statusLabelBottom sizeToFit];
    CGFloat x = self.frame.size.width - 15.0f - self.statusLabelTop.frame.size.width;
    CGFloat y = 11.0f;
    self.statusLabelTop.frame = (CGRect){{x, y}, self.statusLabelTop.bounds.size};
    x = self.frame.size.width - 15.0f - self.statusLabelBottom.frame.size.width;
    y = 33.0f;
    self.statusLabelBottom.frame = (CGRect){{x, y}, self.statusLabelBottom.bounds.size};
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];

    // Position status label
    [self.statusLabelTop sizeToFit];
    [self.statusLabelBottom sizeToFit];
    CGFloat x = self.frame.size.width - 15.0f - self.statusLabelTop.frame.size.width;
    CGFloat y = 11.0f;
    self.statusLabelTop.frame = (CGRect){{x, y}, self.statusLabelTop.bounds.size};
    x = self.frame.size.width - 15.0f - self.statusLabelBottom.frame.size.width;
    y = 33.0f;
    self.statusLabelBottom.frame = (CGRect){{x, y}, self.statusLabelBottom.bounds.size};
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (animated) {
        [UIView animateWithDuration:0.3f animations:^{
            if (selected) {
                self.contentView.backgroundColor = [UIColor colorFromHex:@"#f2f2f2"];
            } else {
                self.contentView.backgroundColor = cellBackgroundColor;
            }
        }];
    } else {
        if (selected) {
            self.contentView.backgroundColor = [UIColor colorFromHex:@"#f2f2f2"];
        } else {
            self.contentView.backgroundColor = cellBackgroundColor;
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    if (animated) {
        [UIView animateWithDuration:0.3f animations:^{
            if (highlighted) {
                self.contentView.backgroundColor = [UIColor colorFromHex:@"#f2f2f2"];
            } else {
                self.contentView.backgroundColor = cellBackgroundColor;
            }
        }];
    } else {
        if (highlighted) {
            self.contentView.backgroundColor = [UIColor colorFromHex:@"#f2f2f2"];
        } else {
            self.contentView.backgroundColor = cellBackgroundColor;
        }
    }
}

@end