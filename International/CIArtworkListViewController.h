//
//  CIArtworkListViewController.h
//  International
//
//  Created by Dimitry Bentsionov on 7/8/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CIArtworkListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *artworkTableView;
    NSArray *artworks;
}

@property (nonatomic, retain) CICategory *category;
@property (nonatomic, retain) NSArray *artworks;
@property (nonatomic, retain) NSString *parentMode;

@end