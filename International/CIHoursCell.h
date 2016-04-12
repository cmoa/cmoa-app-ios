//
//  CIHoursCell.h
//  International
//
//  Created by Dimitry Bentsionov on 8/6/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIExhibitionCell.h"

@interface CIHoursCell : CIExhibitionCell {
    UIColor *cellBackgroundColor;
}

@property (nonatomic, retain) UILabel *statusLabelTop;
@property (nonatomic, retain) UILabel *statusLabelBottom;

- (void)setCellAsHours;
- (void)setTodayAsOpen:(BOOL)open;
- (NSString *)titleForHours:(id)hours;

@end