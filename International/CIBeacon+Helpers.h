//
//  CIBeacon+Helpers.h
//  International
//
//  Created by Dimitry Bentsionov on 7/8/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIBeacon.h"

@interface CIBeacon (Helpers)

+ (NSString*)entityName;
+ (CIBeacon*)findFirstOrCreateByAttribute:(NSString*)attribute withValue:(id)value usingData:(NSDictionary*)data;
- (NSDictionary*)toDictionary;

#pragma mark - Relationships

- (id)findContentLinkedTo;
+ (CIBeacon *)findBeaconWithMajor:(NSNumber *)major andMinor:(NSNumber *)minor;

@end