//
//  CIAudioCell.m
//  International
//
//  Created by Dimitry Bentsionov on 8/2/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIAudioCell.h"

@implementation CIAudioCell

@synthesize medium = _medium;
@synthesize audioView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self postInit];
    }
    return self;
}

- (void)postInit {
//    // Configure styles
//    self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0f];
//    self.textLabel.textColor = [UIColor colorFromHex:@"#556270"];

    // Init the audio view
    audioView = [[CIAudioView alloc] init];
    audioView.forceHideMore = YES;
    [self addSubview:audioView];
}

- (void)setMedium:(CIMedium *)medium {
    _medium = medium;
    audioView.medium = medium;
//    self.textLabel.text = medium.title;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Update lbl location
//    self.textLabel.frame = (CGRect){{15.0f, 12.0f}, self.textLabel.frame.size};

    // Configure size of audio view
//    CGFloat y = self.textLabel.frame.origin.y + self.textLabel.frame.size.height;
//    CGFloat height = self.bounds.size.height - y;
//    audioView.frame = (CGRect){{0.0f, y}, {self.bounds.size.width, height}};
    audioView.frame = self.bounds;
    [audioView updateConstraints];
}

@end