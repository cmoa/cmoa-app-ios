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
@property (nonatomic) CBPeripheralManager *bluetoothPeripheralManager;

@property (nonatomic) _Bool hasAlwaysAuthorization;
@property (nonatomic) _Bool hasBluetoothActive;
@property (nonatomic) _Bool hasFinishedSyncing;

@property (nonatomic, strong) NSNumber *lastBeaconMajor;
@property (nonatomic, strong) NSNumber *lastBeaconMinor;

@property (nonatomic, strong) NSNumber *shownBeaconMajor;
@property (nonatomic, strong) NSNumber *shownBeaconMinor;

@end

@implementation CIBeaconManager

@synthesize beaconManager;
@synthesize bluetoothPeripheralManager;

@synthesize hasAlwaysAuthorization;
@synthesize hasBluetoothActive;
@synthesize hasFinishedSyncing;

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
        hasAlwaysAuthorization = false;
        hasBluetoothActive = false;
        hasFinishedSyncing = false;
        
        self.beaconManager = [ESTBeaconManager new];
        self.beaconManager.delegate = self;
        
        NSDictionary *dontShowBluetoothAlert = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:CBCentralManagerOptionShowPowerAlertKey];
        self.bluetoothPeripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:NULL options:dontShowBluetoothAlert];
        [self addObservers];
    }
    return self;
}

- (void) start {
    // Empty on purpose
    // Merely makes the shared instance call look better
}
         
 - (void) addObservers {
     NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
     [nc addObserver:self
            selector:@selector(beaconContentHidden:)
                name:kCIBeaconContentHiddenNotification
              object:nil];
     [nc addObserver:self
            selector:@selector(finishedSyncing)
                name:@"DidFinishSync"
              object:nil];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) finishedSyncing {
    hasFinishedSyncing = true;
    [self startMonitoring];
}

- (void) startMonitoring {
    if (hasBluetoothActive == false ||
        hasAlwaysAuthorization == false ||
        hasFinishedSyncing == false) {
        return;
    }
    
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

- (void)beaconManager:(id)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region {
    CLBeacon *closestBeacon = beacons.firstObject;
    
    if (closestBeacon == nil) {
        return;
    }
    
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
    
    id beaconContent = [beacon findContentLinkedTo];
    
    if ([beaconContent isKindOfClass:[CIArtwork class]]) {
        CIArtwork *beaconArtwork = (CIArtwork *)beaconContent;
        
        // Don't display beacons that have no content
        if (beaconArtwork == nil) {
            return;
        }
        
        NSString *notificationTitle = [NSString stringWithFormat:@"You are near %@",  beaconArtwork.title];
        [self showBeaconNotification:notificationTitle
                    interactionBlock:^(CRToastInteractionType interactionType) {
            [self hidePreviousBeaconContentIfExists];
            shownBeaconMajor = beacon.major;
            shownBeaconMinor = beacon.minor;
                        
            [CIAnalyticsHelper sendEventWithCategory:@"Beacon"
                                           andAction:@"Beacon Notification Tapped"
                                            andLabel:beacon.name];
                        
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
        
    } else if ([beaconContent isKindOfClass:[CILocation class]]) {
        CILocation *beaconLocation = (CILocation *)beaconContent;
        
        // Don't display beacons that have no content
        if (beaconLocation == nil) {
            return;
        }
        
        NSString *notificationTitle = [NSString stringWithFormat:@"You are in %@",  beaconLocation.name];
        [self showBeaconNotification:notificationTitle interactionBlock:^(CRToastInteractionType interactionType) {
            [self hidePreviousBeaconContentIfExists];
            shownBeaconMajor = beacon.major;
            shownBeaconMinor = beacon.minor;
            
            [CIAnalyticsHelper sendEventWithCategory:@"Beacon"
                                           andAction:@"Beacon Notification Tapped"
                                            andLabel:beacon.name];
            
            [CIAnalyticsHelper sendEventWithCategory:@"Location"
                                           andAction:@"Location Viewed"
                                            andLabel:beaconLocation.name];
            
            NSString *storyboardName = IS_IPHONE ? @"Main_iPhone" : @"Main_iPad";
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
            
            CIArtworkTabsViewController *artworkTabsViewController = [storyboard instantiateViewControllerWithIdentifier:@"ArtworkTabsViewController"];
            
            UIViewController *rootController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
            
            // Setup view
            // Each CIArtworkTabsViewController tab has it's own navigation controller
            // So we pass persistDoneButton to CIArtworkTabsViewController and it passes it to
            // each of it's sub navigation controllers.
            artworkTabsViewController.persistDoneButton = true;
            artworkTabsViewController.displayingBeaconContent = true;
            [CIAppState sharedAppState].currentLocation = beaconLocation;
            
            [rootController presentViewController:artworkTabsViewController animated:YES completion:nil];
        }];
    } else {
        // Don't display beacons that have no content
        return;
    }
    
    // Update the last beacon
    lastBeaconMajor = closestBeacon.major;
    lastBeaconMinor = closestBeacon.minor;
}

- (void)showBeaconNotification:(NSString *)notificationTitle
              interactionBlock:(void (^) (CRToastInteractionType interactionType))interactionBlock {
    
    NSMutableDictionary *options = [@{
                              kCRToastTimeIntervalKey : @5.0,
                              kCRToastUnderStatusBarKey: @YES,
                              kCRToastNotificationPresentationTypeKey : @(CRToastPresentationTypeCover),
                              kCRToastNotificationTypeKey : @(CRToastTypeNavigationBar),
                              kCRToastTextKey : notificationTitle,
                              kCRToastTextMaxNumberOfLinesKey : @2,
                              kCRToastFontKey : [UIFont fontWithName:@"HelveticaNeue" size:15.0f],
                              kCRToastSubtitleFontKey : [UIFont fontWithName:@"HelveticaNeue" size:12.0f],
                              kCRToastTextAlignmentKey : @(NSTextAlignmentLeft),
                              kCRToastSubtitleTextKey : @"Tap to view",
                              kCRToastSubtitleTextAlignmentKey : @(NSTextAlignmentLeft),
                              kCRToastBackgroundColorKey : [UIColor colorFromHex:kCIBlackTextColor],
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
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        hasAlwaysAuthorization = true;
        [self startMonitoring];
    } else if (status == kCLAuthorizationStatusNotDetermined) {
        [beaconManager requestAlwaysAuthorization];
        hasAlwaysAuthorization = false;
    } else {
        hasAlwaysAuthorization = false;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Authorization"
                                                        message:@"Please enable Gallery Guide location access in Settings to 'Always' if you wish for Gallery Guide to provide you with information about objects close to you."
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - CBPeripheralManager delegate

- (void) peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    if (peripheral.state == CBPeripheralManagerStatePoweredOn) {
        hasBluetoothActive = true;
        [self startMonitoring];
    } else if (peripheral.state == CBPeripheralManagerStateUnsupported) {
        // Simulator
        hasBluetoothActive = false;
    } else {
        hasBluetoothActive = false;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bluetooth Status"
                                                        message:@"Please enable bluetooth if you wish for Gallery Guide to provide you with information about objects close to you."
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

@end
