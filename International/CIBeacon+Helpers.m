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
    beacon.locationUuid = [CIData objValueOrNilForKey:@"location_uuid" data:data];
    beacon.artworkUuid = [CIData objValueOrNilForKey:@"artwork_uuid" data:data];
    
    return beacon;
}

- (NSDictionary*)toDictionary {
    return @{
             @"uuid" : self.uuid,
             @"locationUuid" : [CIData objOrNSNull:self.locationUuid],
             @"artworkUuid" : [CIData objOrNSNull:self.artworkUuid],
             
             @"major" : [CIData objOrNSNull:self.major],
             @"minor" : [CIData objOrNSNull:self.minor],
             @"name" : [CIData objOrNSNull:self.name],
             };
}

#pragma mark - Relationships

- (id)findContentLinkedTo {
    if (self.locationUuid) {
        NSPredicate *locationPredicate = [NSPredicate predicateWithFormat:@"uuid == %@", self.locationUuid];
        CILocation *location = [CILocation MR_findFirstWithPredicate:locationPredicate];
        
        if ([[location liveArtworks] count] > 0) {
            return location;
        } else {
            return nil;
        }
        
    } else if (self.artworkUuid) {
        NSPredicate *artworkPredicate = [NSPredicate predicateWithFormat:@"uuid == %@", self.artworkUuid];
        CIArtwork *artwork = [CIArtwork MR_findFirstWithPredicate:artworkPredicate];
        
        if ([[CIExhibition liveExhibitionUuids] containsObject:artwork.exhibitionUuid]) {
            return artwork;
        } else {
            return nil;
        }
        
    } else {
        return nil;
    }
}

+ (CIBeacon *)findBeaconWithMajor:(NSNumber *)major andMinor:(NSNumber *)minor {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(major == %@) AND (minor == %@)", major, minor];
    
    return [CIBeacon MR_findFirstWithPredicate:predicate];
}

@end