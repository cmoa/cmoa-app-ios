//
//  CIArtworkTabsViewController.m
//  International
//
//  Created by Dimitry Bentsionov on 7/24/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIArtworkTabsViewController.h"
#import "CINavigationItem.h"

@interface CIArtworkTabsViewController ()

@end

@implementation CIArtworkTabsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Modify tab bar
    self.tabBar.backgroundImage = [UIImage imageNamed:@"tab_bg"];
    self.tabBar.shadowImage = [[UIImage alloc] init];
    self.tabBar.tintColor = [UIColor colorFromHex:@"#f26361"];
}

- (void)viewWillAppear:(BOOL)animated {
    // Hide the navigation bar
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end