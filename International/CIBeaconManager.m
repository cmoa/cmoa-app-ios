//
//  CIBeaconManager.m
//  CMOA
//
//  Created by Ruben Niculcea on 2/25/16.
//  Copyright © 2016 Carnegie Museums. All rights reserved.
//

#import "CIBeaconManager.h"

#import "CIArtworkDetailViewController.h"
#import "CIArtworkTabsViewController.h"

@interface CIBeaconManager ()

#define kBEACONREGION @"62E67D8F-174A-4436-A6FF-8079D642FB37"
#define kBEACONREGIONNAME @"Carnegie Museum of Art and Natural History"

@property (nonatomic) ESTBeaconManager *beaconManager;

@property (nonatomic, strong) NSNumber *lastBeaconMajor;
@property (nonatomic, strong) NSNumber *lastBeaconMinor;

@property (nonatomic, strong) NSNumber *shownBeaconMajor;
@property (nonatomic, strong) NSNumber *shownBeaconMinor;

@end

@implementation CIBeaconManager

@synthesize beaconManager;

@synthesize lastBeaconMajor;
@synthesize lastBeaconMinor;

@synthesize shownBeaconMajor;
@synthesize shownBeaconMinor;

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
        [self addObservers];
    }
    return self;
}
         
 - (void) addObservers {
     NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
     [nc addObserver:self
            selector:@selector(beaconContentHidden:)
                name:kCIBeaconContentHiddenNotification
              object:nil];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    if ([lastBeaconMajor intValue] == [closestBeacon.major intValue] &&
        [lastBeaconMinor intValue] == [closestBeacon.minor intValue]) {
        return;
    }
    
    // Don't display the currently displaed beacon
    if ([shownBeaconMajor intValue] == [closestBeacon.major intValue] &&
        [shownBeaconMinor intValue] == [closestBeacon.minor intValue]) {
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
            [self hidePreviousBeaconContentIfExists];
            shownBeaconMajor = beacon.major;
            shownBeaconMinor = beacon.minor;
                        
            NSString *storyboardName = IS_IPHONE ? @"Main_iPhone" : @"Main_iPad";
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
                        
            CINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"beaconArtworkView"];
            
            UIViewController *rootController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
                        
            CIArtworkDetailViewController *artworkDetailViewController = (CIArtworkDetailViewController *)navController.topViewController;
            
            // Setup view
            artworkDetailViewController.artworks = @[beaconArtwork];
            artworkDetailViewController.artwork = beaconArtwork;
            artworkDetailViewController.parentMode = @"beacon";
            navController.persistDoneButton = true;
            navController.displayingBeaconContent = true;
            
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
            [self hidePreviousBeaconContentIfExists];
            shownBeaconMajor = beacon.major;
            shownBeaconMinor = beacon.minor;
            
            NSString *storyboardName = IS_IPHONE ? @"Main_iPhone" : @"Main_iPad";
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
            
            CIArtworkTabsViewController *artworkTabsViewController = [storyboard instantiateViewControllerWithIdentifier:@"ArtworkTabsViewController"];
            
            UIViewController *rootController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
            
            // Setup view
            // Each CIArtworkTabsViewController tab sses it's own navigation controller
            // So we pass persistDoneButton to CIArtworkTabsViewController and it passes it to
            // each of it's sub navigation controllers.
            artworkTabsViewController.persistDoneButton = true;
            artworkTabsViewController.displayingBeaconContent = true;
            [CIAppState sharedAppState].currentLocation = beaconLocation;
            
            [rootController presentViewController:artworkTabsViewController animated:YES completion:nil];
        }];
    }
    
    // Update the last beacon
    lastBeaconMajor = closestBeacon.major;
    lastBeaconMinor = closestBeacon.minor;
}

- (void)showBeaconNotification:(NSString *)notificationTitle
              interactionBlock:(void (^) (CRToastInteractionType interactionType))interactionBlock {
    
    // TODO: Change display style for iPad
    // TODO: Change font style to match App style
    
    NSMutableDictionary *options = [@{
                              kCRToastTimeIntervalKey : @5.0,
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
    
    
    // TODO: How do we make this accessable?
    options[kCRToastInteractionRespondersKey] = @[
            [CRToastInteractionResponder interactionResponderWithInteractionType:CRToastInteractionTypeTap
                                                            automaticallyDismiss:YES
                                                                           block:interactionBlock],
            [CRToastInteractionResponder interactionResponderWithInteractionType:CRToastInteractionTypeSwipe
                                                            automaticallyDismiss:YES
                                                                           block:^(CRToastInteractionType interactionType) {
                                                                               [CRToastManager dismissNotification:YES];
                                                                           }]];
    
    [CRToastManager showNotificationWithOptions:options
                                completionBlock:nil];
}

- (void)hidePreviousBeaconContentIfExists {
    if (shownBeaconMajor != nil && shownBeaconMinor != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kCIHideBeaconContentNotification
                                                            object:nil];
    }
}

#pragma mark - Beacon notifications

- (void)beaconContentHidden:(NSNotification *)note {
    shownBeaconMajor = nil;
    shownBeaconMinor = nil;
    
    // Clear location if set
    CILocation *currentLocation = [CIAppState sharedAppState].currentLocation;
    
    if (currentLocation != nil) {
        currentLocation = nil;
    }
}

#pragma mark - Beacon delegate

- (void)beaconManager:(id)manager monitoringDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"%@", error);
}

- (void)beaconManager:(id)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
}

@end
