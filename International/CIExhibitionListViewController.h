//
//  CIExhibitionListViewController.h
//  International
//
//  Created by Dimitry Bentsionov on 7/22/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CIExhibitionListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *exhibitionsTableView;
    NSArray *exhibitions;
}

@end