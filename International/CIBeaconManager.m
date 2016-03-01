//
//  CIBeaconManager.m
//  CMOA
//
//  Created by Ruben Niculcea on 2/25/16.
//  Copyright © 2016 Carnegie Museums. All rights reserved.
//

#import "CIBeaconManager.h"

#import "CIArtworkDetailViewController.h"

@interface CIBeaconManager ()

#define kBEACONREGION @"62E67D8F-174A-4436-A6FF-8079D642FB37"
#define kBEACONREGIONNAME @"Carnegie Museum of Art and Natural History"

@property (nonatomic) ESTBeaconManager *beaconManager;

@end

@implementation CIBeaconManager

@synthesize beaconManager;

static CIBeaconManager *_sharedInstance = nil;

+ (CIBeaconManager *)sharedInstance {
    @synchronized (self) {
        if (!_sharedInstance) {
            _sharedInstance = [[self alloc] init];
        }
    }
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.beaconManager = [ESTBeaconManager new];
        self.beaconManager.delegate = self;
    }
    return self;
}

- (void) requestAuthorization {
    [self.beaconManager requestAlwaysAuthorization];
    [self startMonitoring];
}

- (void) startMonitoring {
    // Lock screen icon by monitoring for all beacons with Museums beacons UUID
    NSUUID *regionUUID = [[NSUUID alloc] initWithUUIDString:kBEACONREGION];
    
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc]
                                   initWithProximityUUID:regionUUID
                                   identifier:kBEACONREGIONNAME];
    
    // Lock Screen
    [beaconManager startMonitoringForRegion:beaconRegion];
    
    // Monitor Beacons
    [beaconManager startRangingBeaconsInRegion:beaconRegion];
}

- (void)beaconManager:(id)manager didEnterRegion:(CLBeaconRegion *)region {
    NSLog(@"beacon region hit");
}

- (void)beaconManager:(id)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region {
    CLBeacon *closestBeacon = beacons.firstObject;
    
    if (closestBeacon == nil) {
        return;
    }
    
    NSLog(@"beacon major:%@ minor:%@", closestBeacon.major, closestBeacon.minor);
    
    // Don't display the same beacon twice
    if ([[CIAppState sharedAppState].lastBeaconMajor intValue] == [closestBeacon.major intValue] &&
        [[CIAppState sharedAppState].lastBeaconMinor intValue] == [closestBeacon.minor intValue]) {
        return;
    }
    
    // Don't display beacons that are far away
    if (closestBeacon.proximity == CLProximityFar) {
        return;
    }
    
    CIBeacon* beacon = [CIBeacon findBeaconWithMajor:closestBeacon.major andMinor:closestBeacon.minor];
    
    // Don't display beacons that have no content
    if (beacon == nil) {
        return;
    }
    
    CIArtwork *beaconArtwork = [CIArtwork artworkWithBeacon:beacon];
    if (beaconArtwork) {
        
        NSString *notificationTitle = [NSString stringWithFormat:@"You are near %@",  beaconArtwork.title];
        [self showBeaconNotification:notificationTitle
                    interactionBlock:^(CRToastInteractionType interactionType) {
                        
            NSLog(@"Hit");
                        
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            CINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"beaconArtworkView"];
            
            UIViewController *rootController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
                        
            CIArtworkDetailViewController *artworkDetailViewController = (CIArtworkDetailViewController *)navController.topViewController;
            
            artworkDetailViewController.artworks = @[beaconArtwork];
            artworkDetailViewController.artwork = beaconArtwork;
            artworkDetailViewController.parentMode = @"beacon";
            
            [rootController presentViewController:navController animated:YES completion:nil];
        }];
        
    } else {
        CILocation *beaconLocation = [CILocation locationWithBeacon:beacon];
        
        // Don't display beacons that have no content
        if (beaconLocation == nil) {
            return;
        }
        
        NSString *notificationTitle = [NSString stringWithFormat:@"You are in %@",  beaconLocation.name];
        [self showBeaconNotification:notificationTitle interactionBlock:^(CRToastInteractionType interactionType) {
            NSLog(@"Hit 2");
        }];
    }
    
    [CIAppState sharedAppState].lastBeaconMajor = closestBeacon.major;
    [CIAppState sharedAppState].lastBeaconMinor = closestBeacon.minor;
}

- (void)showBeaconNotification:(NSString *)notificationTitle
              interactionBlock:(void (^) (CRToastInteractionType interactionType))interactionBlock {
    NSMutableDictionary *options = [@{
                              kCRToastTimeIntervalKey : @15.0,
                              kCRToastUnderStatusBarKey: @YES,
                              kCRToastNotificationPresentationTypeKey : @(CRToastPresentationTypeCover),
                              kCRToastNotificationTypeKey : @(CRToastTypeNavigationBar),
                              kCRToastTextKey : notificationTitle,
                              kCRToastTextMaxNumberOfLinesKey : @2,
                              kCRToastTextAlignmentKey : @(NSTextAlignmentLeft),
                              kCRToastSubtitleTextKey : @"Tap to view",
                              kCRToastSubtitleTextAlignmentKey : @(NSTextAlignmentLeft),
                              kCRToastBackgroundColorKey : [UIColor colorFromHex:kCIAccentColor],
                              kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                              kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop),
                              kCRToastAnimationInTypeKey : @(CRToastAnimationTypeLinear),
                              kCRToastAnimationInTypeKey : @(CRToastAnimationTypeSpring),
                              kCRToastImageKey : [UIImage imageNamed:@"closeNotification.png"],
                              kCRToastImageAlignmentKey : @(NSTextAlignmentRight),
                              } mutableCopy];
    
    options[kCRToastInteractionRespondersKey] = @[
            [CRToastInteractionResponder interactionResponderWithInteractionType:CRToastInteractionTypeTap
                                                            automaticallyDismiss:YES
                                                                           block:interactionBlock]];
    
    [CRToastManager showNotificationWithOptions:options
                                completionBlock:nil];
}

- (void)beaconManager:(id)manager monitoringDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"%@", error);
}

- (void)beaconManager:(id)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
}

@end
