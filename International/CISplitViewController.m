//
//  CISplitViewController.m
//  CMOA
//
//  Created by Dimitry Bentsionov on 9/11/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CISplitViewController.h"

@interface CISplitViewController ()

@end

@implementation CISplitViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        self.delegate = self;
//        isMasterViewHidden = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
//        self.delegate = self;
//        isMasterViewHidden = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)hideMasterViewController {
//    isMasterViewHidden = YES;
//    [self willRotateToInterfaceOrientation:self.interfaceOrientation duration:0.0f];
//    [self.view setNeedsLayout];
//}

//- (void)showMasterViewController {
//    isMasterViewHidden = NO;
//    [self willRotateToInterfaceOrientation:self.interfaceOrientation duration:0.0f];
//    [self.view setNeedsLayout];
//}

#pragma mark - Split view delegate

//- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
//    return isMasterViewHidden;
//}

@end