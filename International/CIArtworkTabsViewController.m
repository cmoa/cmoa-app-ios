//
//  CIArtworkTabsViewController.m
//  International
//
//  Created by Dimitry Bentsionov on 7/24/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIArtworkTabsViewController.h"
#import "CINavigationItem.h"

@implementation CIArtworkTabsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.persistDoneButton = false;
        self.displayingBeaconContent = false;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.persistDoneButton) {
        for (CINavigationController *navController in self.viewControllers) {
            navController.persistDoneButton = true;
            
            if (self.persistDoneButton) {
                navController.displayingBeaconContent = true;
            }
        }
    }
    
    // Modify tab bar
    self.tabBar.barTintColor = [UIColor colorFromHex:kCIBarColor];
    self.tabBar.tintColor = [UIColor colorFromHex:kCILinkColor];
}

- (void)viewWillAppear:(BOOL)animated {
    // Hide the navigation bar
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end