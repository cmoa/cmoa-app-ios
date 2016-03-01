//
//  CILocation+Helpers.m
//  International
//
//  Created by Dimitry Bentsionov on 8/1/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CILocation+Helpers.h"

@implementation CILocation (Helpers)

+ (NSString*)entityName {
    return NSStringFromClass(self);
}

+ (CILocation*)findFirstOrCreateByAttribute:(NSString*)attribute withValue:(id)value usingData:(NSDictionary*)data {
    CILocation *location = [CILocation MR_findFirstByAttribute:attribute withValue:value];
    if (location == nil) {
        location = [CILocation MR_createEntity];
    }
    
    // Parse the rest of the data and update the model object
    location.uuid = [data objectForKey:@"uuid"];
    location.createdAt = [CIData dateValueOrNilForKey:@"created_at" data:data];
    location.updatedAt = [CIData dateValueOrNilForKey:@"updated_at" data:data];
    location.deletedAt = [CIData dateValueOrNilForKey:@"deleted_at" data:data];
    
    location.name = [CIData objValueOrNilForKey:@"name" data:data];
    location.beaconUuid = [CIData objValueOrNilForKey:@"beacon_uuid" data:data];
    
    // Mark as 'not changed'
    location.syncStatus = [NSNumber numberWithInteger:CISyncStatusNotChanged];
    
    return location;
}

- (NSDictionary*)toDictionary {
    return @{
             @"uuid" : self.uuid,
             @"created_at" : [CIData dateOrNSNull:self.createdAt],
             @"updated_at" : [CIData dateOrNSNull:self.updatedAt],
             @"deleted_at" : [CIData dateOrNSNull:self.deletedAt],
             
             @"name" : [CIData objOrNSNull:self.name],
             @"beacon_uuid" : [CIData objOrNSNull:self.beaconUuid]
             };
}

#pragma mark - Relationships

+ (CILocation *)locationWithBeacon:(CIBeacon *)beacon {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(beaconUuid = %@)", beacon.uuid];
    CILocation *location = [CILocation MR_findFirstWithPredicate:predicate];
    
    if (location == nil) {
        return nil;
    } else {
        return location;
    }
}

- (NSArray*)artists {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (locationUuid == %@)", self.uuid];
  NSArray *artists = [CIArtist MR_findAllWithPredicate:predicate];
  
  // Return results sorted
  NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
  return [artists sortedArrayUsingDescriptors:@[sort]];
}

- (NSArray*)artistArtworks {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (locationUuid == %@)", self.uuid];
  return [CIArtistArtwork MR_findAllWithPredicate:predicate];
}

- (NSArray*)artworks {
  // Default sorting by code
  return [self artworksSortedBy:@"code" ascending:YES];
}

- (NSArray*)artworksSortedBy:(NSString *)sortedBy ascending:(BOOL)ascending {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (locationUuid == %@)", self.uuid];
  return [CIArtwork MR_findAllSortedBy:sortedBy ascending:ascending withPredicate:predicate];
}

- (NSArray*)liveArtworks {
    NSMutableArray *liveArtworks = [[NSMutableArray alloc] init];
    NSArray *liveExhibitionsUUIDs = [CIExhibition liveExhibitionUuids];
    
    for (CIArtwork *artwork in self.artworks) {
        if ([liveExhibitionsUUIDs containsObject:artwork.exhibitionUuid]) {
            [liveArtworks addObject:artwork];
        }
    }
    
    return liveArtworks;
}

- (NSArray*)liveArtworksSortedBy:(NSString *)sortedBy ascending:(BOOL)ascending {
    NSMutableArray *liveArtworks = [[NSMutableArray alloc] init];
    NSMutableArray *liveExhibitionsUUIDs = [[NSMutableArray alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (isLive = YES)"];
    
    for (CIExhibition *exhibition in [CIExhibition MR_findAllWithPredicate:predicate]) {
        [liveExhibitionsUUIDs addObject:exhibition.uuid];
    }
    
    for (CIArtwork *artwork in [self artworksSortedBy:sortedBy ascending:ascending]) {
        if ([liveExhibitionsUUIDs containsObject:artwork.exhibitionUuid]) {
            [liveArtworks addObject:artwork];
        }
    }
    
    return liveArtworks;
}

- (NSArray*)media {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (locationUuid == %@)", self.uuid];
  return [CIMedium MR_findAllWithPredicate:predicate];
}

@end