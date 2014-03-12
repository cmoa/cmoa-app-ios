//
//  CIViewController.h
//  International
//
//  Created by Dimitry Bentsionov on 7/3/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CIArtistListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *artistTableView;
    NSArray *artists;
}

@property (nonatomic, retain) NSArray *artists;
@property (nonatomic, retain) NSString *parentMode;

@end