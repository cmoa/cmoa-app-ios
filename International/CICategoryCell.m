//
//  CICategoryCell.m
//  CMOA
//
//  Created by Dimitry Bentsionov on 8/13/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CICategoryCell.h"

@implementation CICategoryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self loadStyles];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (animated) {
        [UIView animateWithDuration:0.3f animations:^{
            if (selected) {
                self.contentView.backgroundColor = [UIColor colorFromHex:@"#f2f2f2"];
            } else {
                self.contentView.backgroundColor = [UIColor colorFromHex:@"#ffffff"];
            }
        }];
    } else {
        if (selected) {
            self.contentView.backgroundColor = [UIColor colorFromHex:@"#f2f2f2"];
        } else {
            self.contentView.backgroundColor = [UIColor colorFromHex:@"#ffffff"];
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
                self.contentView.backgroundColor = [UIColor colorFromHex:@"#ffffff"];
            }
        }];
    } else {
        if (highlighted) {
            self.contentView.backgroundColor = [UIColor colorFromHex:@"#f2f2f2"];
        } else {
            self.contentView.backgroundColor = [UIColor colorFromHex:@"#ffffff"];
        }
    }
}

- (void)loadStyles {
    self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    self.textLabel.textColor = [UIColor colorFromHex:@"#556270"];
    self.textLabel.highlightedTextColor = [UIColor colorFromHex:@"#556270"];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.frame = (CGRect){{15.0f, 0.0f}, self.textLabel.frame.size};
}

@end
