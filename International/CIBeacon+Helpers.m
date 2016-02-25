//
//  CIBeacon+Helpers.m
//  International
//
//  Created by Dimitry Bentsionov on 7/8/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIBeacon+Helpers.h"

@implementation CIBeacon (Helpers)

+ (NSString*)entityName {
    return NSStringFromClass(self);
}

+ (CIBeacon*)findFirstOrCreateByAttribute:(NSString*)attribute withValue:(id)value usingData:(NSDictionary*)data {
    CIBeacon *beacon = [CIBeacon MR_findFirstByAttribute:attribute withValue:value];
    if (beacon == nil) {
        beacon = [CIBeacon MR_createEntity];
    }
    
    // Parse the rest of the data and update the model object
    beacon.uuid = [data objectForKey:@"uuid"];
    beacon.major = [CIData objValueOrNilForKey:@"major" data:data];
    beacon.minor = [CIData objValueOrNilForKey:@"minor" data:data];
    beacon.name = [CIData objValueOrNilForKey:@"name" data:data];
    
    return beacon;
}

- (NSDictionary*)toDictionary {
    return @{
             @"uuid" : self.uuid,
             @"major" : [CIData objOrNSNull:self.major],
             @"minor" : [CIData objOrNSNull:self.minor],
             @"name" : [CIData objOrNSNull:self.name],
             };
}

#pragma mark - Relationships

+ (CIBeacon *)findBeaconWithMajor:(NSNumber *)major andMinor:(NSNumber *)minor {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(major = nil) AND (minor == %@)", major, minor];
    
    return [CIBeacon MR_findFirstWithPredicate:predicate];
}

@end