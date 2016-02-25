//
//  CIBeaconManager.m
//  CMOA
//
//  Created by Ruben Niculcea on 2/25/16.
//  Copyright © 2016 Carnegie Museums. All rights reserved.
//

#import "CIBeaconManager.h"
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
    
    if (closestBeacon.proximity == CLProximityFar) {
        return;
    }
    
    CIBeacon* beacon = [CIBeacon findBeaconWithMajor:region.major andMinor:region.minor];
    
    if (beacon == nil) {
        return;
    }
    
    NSLog(@"known beacon");
}

- (void)beaconManager:(id)manager monitoringDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    
}

- (void)beaconManager:(id)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
}

@end
