//
//  CIAppDelegate.m
//  International
//
//  Created by Dimitry Bentsionov on 7/3/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIAppDelegate.h"

@implementation CIAppDelegate

@synthesize analyticsTracker;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window.tintColor = [UIColor colorFromHex:kCIAccentColor];
    
    // Back main window bg color to white. Helps with custom view transitions
    self.window.backgroundColor = [UIColor whiteColor];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];

    // Fix bug that would render white line between Master and Detail on iPad
    // This is due to some layer inserting a white line between at this position, who's inserting it? No idea...
    if (IS_IPAD) {
        CGFloat xPos = 320;
        CGFloat width = 1;
        
        if (IS_IPAD_PRO) {
            xPos = 375;
            width = 0.5;
        }
        
        UIView *statusBarBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(xPos, 0, width, 20)];
        statusBarBackgroundView.backgroundColor = [UIColor colorFromHex:@"8e8e93"];
        [self.window.rootViewController.view addSubview:statusBarBackgroundView];
    }
    
    // Verify API config file presence
    NSString* settingsFilePath = [[NSBundle mainBundle] pathForResource:@"settings"
                                                                 ofType:@"plist"];
    assert([[NSFileManager defaultManager] fileExistsAtPath:settingsFilePath]);

    // Prepare MagicalRecord (CoreData): Uses versioned file names. Ex: CIData-1.2.1.sqlite
    NSString *appNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *appVersion = [NSString stringWithFormat:@"%@.%@", appNumber, buildNumber];
    [MagicalRecord setupCoreDataStackWithStoreNamed:[NSString stringWithFormat:@"CIData-%@.sqlite", appVersion]];
    
    // Google Analytics setup
    self.analyticsTracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-43659554-1"];
    
    // Start the beacon manager
    [CIBeaconManager sharedInstance];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end