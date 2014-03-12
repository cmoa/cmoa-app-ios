//
//  CIArtworkCategoryListViewController.h
//  CMOA
//
//  Created by Dimitry Bentsionov on 8/13/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CICategoryListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *categoriesTableView;
    NSArray *categories;
}

@end