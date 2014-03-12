//
//  CIExhibitionCell.h
//  International
//
//  Created by Dimitry Bentsionov on 7/23/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CIExhibitionCell : UITableViewCell {
    UIImageView *imgAudio;
    UIImageView *imgVideo;
}

- (void)configureCell;
- (void)cellEnabled:(BOOL)enabled;
- (void)setIdentificationWithAudio:(BOOL)hasAudio withVideo:(BOOL)hasVideo;
- (CGFloat)getHeightInTableView:(UITableView *)tableView;

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *subtitleLabel;
@property (nonatomic) BOOL constraintsUpdated;

@end