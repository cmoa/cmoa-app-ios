//
//  CIAppDelegate.h
//  International
//
//  Created by Dimitry Bentsionov on 7/3/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CIAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) id<GAITracker> analyticsTracker;

@end