//
//  CIVideoPlayerViewController.m
//  CMOA
//
//  Created by Dimitry Bentsionov on 8/15/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIVideoPlayerViewController.h"

@interface CIVideoPlayerViewController ()

@end

@implementation CIVideoPlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    // Analytics
    [CIAnalyticsHelper sendScreen:@"Video Player"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
}

@end