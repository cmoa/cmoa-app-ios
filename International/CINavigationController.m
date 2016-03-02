//
//  CINavigationController.m
//  International
//
//  Created by Dimitry Bentsionov on 7/22/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CINavigationController.h"

#import "CINavigationItem.h"

@interface CINavigationController () <UINavigationControllerDelegate>

@property (nonatomic) IBInspectable BOOL persistDoneButton;
@property (nonatomic) UIBarButtonItem *doneButton;

@end

@implementation CINavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.persistDoneButton = false;
        self.delegate = self;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.persistDoneButton = false;
        self.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.persistDoneButton) {
        if (!viewController.navigationItem.rightBarButtonItem) {
            if (self.doneButton == nil) {
                self.doneButton = [CINavigationItem buildBackButtonWithTarget:self action:@selector(dismiss)];
            }
            
            [viewController.navigationItem setRightBarButtonItem:self.doneButton];
        }
    }
}

- (void) dismiss {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
