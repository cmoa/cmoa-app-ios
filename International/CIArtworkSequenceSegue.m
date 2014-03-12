//
//  CIArtworkSequenceSegue.m
//  International
//
//  Created by Dimitry Bentsionov on 7/31/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CIArtworkSequenceSegue.h"

@implementation CIArtworkSequenceSegue

- (void)perform {
    // Grab our view controllers
    UIViewController *sourceViewController = (UIViewController*)self.sourceViewController;
    UIViewController *destinationController = (UIViewController*)self.destinationViewController;
    
    // Define the transition
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    transition.type = kCATransitionReveal;
    
    // Fade left or right?
    if ([self.identifier isEqualToString:@"showPrevArtworkDetail"] || [self.identifier isEqualToString:@"showPrevArtistDetail"]) {
        transition.subtype = kCATransitionFromLeft;
    } else if ([self.identifier isEqualToString:@"showNextArtworkDetail"] || [self.identifier isEqualToString:@"showNextArtistDetail"]) {
        transition.subtype = kCATransitionFromRight;
    }
    
    // Animation
    [sourceViewController.navigationController.view.layer addAnimation:transition
                                                                forKey:kCATransition];
    
    // Navigation controller
    [sourceViewController.navigationController pushViewController:destinationController
                                                         animated:NO];
}

@end