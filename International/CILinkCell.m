//
//  CILinkCell.m
//  CMOA
//
//  Created by Dimitry Bentsionov on 8/12/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CILinkCell.h"

@implementation CILinkCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
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

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Update lbl frame
    self.textLabel.frame = (CGRect){{15.0f, self.textLabel.frame.origin.y}, {self.frame.size.width - 30.0f, self.textLabel.frame.size.height}};
    self.textLabel.textColor = [UIColor colorFromHex:@"#556270"];
    self.textLabel.highlightedTextColor = [UIColor colorFromHex:@"#556270"];
    self.detailTextLabel.frame = (CGRect){{15.0f, self.detailTextLabel.frame.origin.y}, {self.frame.size.width - 30.0f, self.detailTextLabel.frame.size.height}};
    self.detailTextLabel.textColor = [UIColor colorFromHex:@"#f26361"];
    self.detailTextLabel.highlightedTextColor = [UIColor colorFromHex:@"#f26361"];
}

@end
