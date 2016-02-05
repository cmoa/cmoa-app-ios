//
//  CIExhibitionCell.m
//  International
//
//  Created by Dimitry Bentsionov on 7/23/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CIExhibitionCell.h"

@implementation CIExhibitionCell

#define kInsetTop 11
#define kInsetBottom 13
#define kInsetLeft 15
#define kInsetRight 15
#define kLabelSpace 7
#define kTitleLabelFont [UIFont fontWithName:@"HelveticaNeue" size:14.0f]
#define kSubtitleLabelFont [UIFont fontWithName:@"HelveticaNeue" size:10.0f]

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configureCell];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [imgAudio removeFromSuperview];
    [imgVideo removeFromSuperview];
    imgAudio = nil;
    imgVideo = nil;
    [self cellEnabled:YES];
}

- (void)configureCell {
    self.constraintsUpdated = NO;
    
    // Title lbl
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = kTitleLabelFont;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.textColor = [UIColor colorFromHex:kCIBlackTextColor];
    self.titleLabel.highlightedTextColor = [UIColor colorFromHex:kCIBlackTextColor];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Subtitle lbl
    self.subtitleLabel = [[UILabel alloc] init];
    self.subtitleLabel.font = kSubtitleLabelFont;
    self.subtitleLabel.numberOfLines = 0;
    self.subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.subtitleLabel.textColor = [UIColor colorFromHex:kCIAccentColor];
    self.subtitleLabel.highlightedTextColor = [UIColor colorFromHex:kCIAccentColor];
    self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Add children
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.subtitleLabel];
    
    // Update constraints
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    if (self.constraintsUpdated == NO) {
        
        int insetTop = kInsetTop;
        int labelSpace = kLabelSpace;
        int insetBottom = kInsetBottom;
        
        // Set label constraints
        NSDictionary *views = @{
                                @"title" : self.titleLabel,
                                @"subtitle" : self.subtitleLabel
                                };
        NSArray *horizontalCon1 = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(%i)-[title]-(%i)-|", kInsetLeft, kInsetRight]
                                                                          options:0
                                                                          metrics:nil
                                                                            views:views];
        NSArray *horizontalCon2 = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(%i)-[subtitle]-(%i)-|", kInsetLeft, kInsetRight]
                                                                          options:0
                                                                          metrics:nil
                                                                            views:views];
        
        if (self.titleLabel.numberOfLines > 1) {
            insetTop = 5;
            labelSpace = 0;
            insetBottom = 8;
        }
        
        NSArray *verticalCon1 = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-(%i)-[title]-(%i)-[subtitle]-(%i)-|", insetTop, labelSpace, insetBottom]
                                                                options:0
                                                                metrics:nil
                                                                  views:views];
        [self.contentView addConstraints:horizontalCon1];
        [self.contentView addConstraints:horizontalCon2];
        [self.contentView addConstraints:verticalCon1];
        self.constraintsUpdated = YES;
    }
    
    // Set default constraints
    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Update contentView's layout
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    // Set preferred width for labels
    self.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabel.frame);
    self.subtitleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.subtitleLabel.frame);
    
    // Identification position
    CGFloat const topOffset = self.frame.size.height - 29.0f;
    if (imgAudio && imgVideo) {
        CGFloat x1 = self.frame.size.width - 12.0f - imgAudio.frame.size.width - imgVideo.frame.size.width;
        CGFloat x2 = self.frame.size.width - 12.0f - imgVideo.frame.size.width;
        imgAudio.frame = (CGRect){{x1, topOffset}, imgAudio.frame.size};
        imgVideo.frame = (CGRect){{x2, topOffset}, imgVideo.frame.size};
    } else if (imgAudio) {
        CGFloat x1 = self.frame.size.width - 12.0f - imgAudio.frame.size.width;
        imgAudio.frame = (CGRect){{x1, topOffset}, imgAudio.frame.size};
    } else if (imgVideo) {
        CGFloat x1 = self.frame.size.width - 12.0f - imgVideo.frame.size.width;
        imgVideo.frame = (CGRect){{x1, topOffset}, imgVideo.frame.size};
    }
}

- (CGFloat)getHeightInTableView:(UITableView *)tableView {
    // Process custom constraints
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    
    // Configure bounds
    self.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(self.bounds));
    
    // Layout subviews
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    // Get the actual height
    CGFloat height = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;

    // Account for the cell separator
    height += 1.0f;
    
    return height;
}

- (void)cellEnabled:(BOOL)enabled {
    if (enabled == YES) {
        self.textLabel.textColor = [UIColor colorFromHex:@"#556270"];
        self.detailTextLabel.textColor = [UIColor colorFromHex:@"#f26361"];
    } else {
        self.textLabel.textColor = [UIColor colorFromHex:@"#959595"];
        self.detailTextLabel.textColor = [UIColor colorFromHex:@"#959595"];
    }
}

- (void)setIdentificationWithAudio:(BOOL)hasAudio withVideo:(BOOL)hasVideo {
    if (hasAudio && hasVideo) {
        imgAudio = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"id_audio"]];
        imgVideo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"id_video"]];
        [self.contentView addSubview:imgAudio];
        [self.contentView addSubview:imgVideo];
    } else if (hasAudio && !hasVideo) {
        imgAudio = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"id_audio"]];
        [self.contentView addSubview:imgAudio];
    } else if (hasVideo && !hasAudio) {
        imgVideo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"id_video"]];
        [self.contentView addSubview:imgVideo];
    }
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

@end