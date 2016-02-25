//
//  CIBeaconManager.h
//  CMOA
//
//  Created by Ruben Niculcea on 2/25/16.
//  Copyright © 2016 Carnegie Museums. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EstimoteSDK/EstimoteSDK.h>

@interface CIBeaconManager : NSObject <ESTBeaconManagerDelegate>

+ (CIBeaconManager *)sharedInstance;

- (void)requestAuthorization;

@end
