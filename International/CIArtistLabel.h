//
//  CIArtistLabel.h
//  International
//
//  Created by Dimitry Bentsionov on 8/6/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CIArtistLabel : UILabel {
    UIView *sepView;
    UIView *sepView2;
}

@property (nonatomic, assign) UIEdgeInsets edgeInsets;

- (void)addTopSeparator;

@end