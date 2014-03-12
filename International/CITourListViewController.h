//
//  CITourListViewController.h
//  International
//
//  Created by Dimitry Bentsionov on 7/31/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CITourListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSArray *tours;
    IBOutlet UITableView *toursTableView;
}

@end