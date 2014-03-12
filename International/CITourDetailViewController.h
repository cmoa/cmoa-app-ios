//
//  CITourDetailViewController.h
//  International
//
//  Created by Dimitry Bentsionov on 7/31/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface CITourDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSArray *artworks;
    IBOutlet UIView *descriptionContainer;
    IBOutlet UIScrollView *descriptionScrollView;
    IBOutlet TTTAttributedLabel *lblDescription;
    IBOutlet UITableView *artworkTableView;
}

@property (nonatomic, retain) CITour *tour;
@property (nonatomic) BOOL isRecommendedTour;

@end