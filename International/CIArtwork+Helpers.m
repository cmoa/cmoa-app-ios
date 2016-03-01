//
//  CIArtwork+Helpers.m
//  International
//
//  Created by Dimitry Bentsionov on 7/8/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIArtwork+Helpers.h"

@implementation CIArtwork (Helpers)

+ (NSString*)entityName {
    return NSStringFromClass(self);
}

+ (CIArtwork*)findFirstOrCreateByAttribute:(NSString*)attribute withValue:(id)value usingData:(NSDictionary*)data {
    CIArtwork *artwork = [CIArtwork MR_findFirstByAttribute:attribute withValue:value];
    if (artwork == nil) {
        artwork = [CIArtwork MR_createEntity];
    }
    
    // Parse the rest of the data and update the model object
    artwork.uuid = [data objectForKey:@"uuid"];
    artwork.createdAt = [CIData dateValueOrNilForKey:@"created_at" data:data];
    artwork.updatedAt = [CIData dateValueOrNilForKey:@"updated_at" data:data];
    artwork.deletedAt = [CIData dateValueOrNilForKey:@"deleted_at" data:data];

    artwork.title = [CIData objValueOrNilForKey:@"title" data:data];
    artwork.code = [CIData objValueOrNilForKey:@"code" data:data];
    artwork.body = [CIData objValueOrNilForKey:@"body" data:data];
    artwork.shareUrl = [CIData objValueOrNilForKey:@"share_url" data:data];
    
    artwork.beaconUuid = [CIData objValueOrNilForKey:@"beacon_uuid" data:data];
    artwork.exhibitionUuid = [CIData objValueOrNilForKey:@"exhibition_uuid" data:data];
    artwork.artistUuid = [CIData objValueOrNilForKey:@"artist_uuid" data:data];
    artwork.categoryUuid = [CIData objValueOrNilForKey:@"category_uuid" data:data];
    artwork.locationUuid = [CIData objValueOrNilForKey:@"location_uuid" data:data];
    
    // Mark as 'not changed'
    artwork.syncStatus = [NSNumber numberWithInteger:CISyncStatusNotChanged];
    
    return artwork;
}

- (NSDictionary*)toDictionary {
    return @{
             @"uuid" : self.uuid,
             @"created_at" : [CIData dateOrNSNull:self.createdAt],
             @"updated_at" : [CIData dateOrNSNull:self.updatedAt],
             @"deleted_at" : [CIData dateOrNSNull:self.deletedAt],

             @"title" : [CIData objOrNSNull:self.title],
             @"code" : [CIData objOrNSNull:self.code],
             @"body" : [CIData objOrNSNull:self.body],
             @"share_url" : [CIData objOrNSNull:self.shareUrl],
             
             @"beaconUuid" : [CIData objOrNSNull:self.beaconUuid],
             @"exhibition_uuid" : [CIData objOrNSNull:self.exhibitionUuid],
             @"artist_uuid" : [CIData objOrNSNull:self.artistUuid],
             @"category_uuid" : [CIData objOrNSNull:self.categoryUuid],
             @"location_uuid" : [CIData objOrNSNull:self.locationUuid]
             };
}

+ (NSArray*)findAllByRecommendedInExhibition:(CIExhibition *)exhibition {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (likes > 0) AND (exhibitionUuid = %@)", exhibition.uuid];
    return [CIArtwork MR_findAllSortedBy:@"likes" ascending:NO withPredicate:predicate];
}

#pragma mark - Relationships

+ (CIArtwork *)artworkWithBeacon:(CIBeacon *)beacon {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(beaconUuid = nil)", beacon.uuid];
    CIArtwork *artwork = [CIArtwork MR_findFirstWithPredicate:predicate];
    
    if (artwork == nil) {
        return nil;
    } else {
        if ([[CIExhibition liveExhibitionUuids] containsObject:artwork.exhibitionUuid]) {
            return artwork;
        } else {
            return nil;
        }
    }
}

- (CIExhibition*)exhibition {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (uuid == %@)", self.exhibitionUuid];
    return [CIExhibition MR_findFirstWithPredicate:predicate];
}

- (NSArray*)artistArtworks {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (artworkUuid == %@)", self.uuid];
    return [CIArtistArtwork MR_findAllWithPredicate:predicate];
}

- (NSArray*)artists {
    NSArray *artistArtworks = [self artistArtworks];
    NSMutableArray *artists = [NSMutableArray arrayWithCapacity:[artistArtworks count]];
    for (CIArtistArtwork *artistArtwork in artistArtworks) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (uuid == %@)", artistArtwork.artistUuid];
        CIArtist *artist = [CIArtist MR_findFirstWithPredicate:predicate];
        if (artist != nil) {
            [artists addObject:artist];
        }
    }
    
    // Return results sorted
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
    return [artists sortedArrayUsingDescriptors:@[sort]];
}

- (CILocation*)location {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (uuid == %@)", self.locationUuid];
    return [CILocation MR_findFirstWithPredicate:predicate];
}

- (CICategory*)category {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (uuid == %@)", self.categoryUuid];
    return [CICategory MR_findFirstWithPredicate:predicate];
}

- (NSArray*)tourArtworks {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (artworkUuid == %@)", self.uuid];
    return [CITourArtwork MR_findAllWithPredicate:predicate];
}

- (NSArray*)tours {
    NSArray *tourArtworks = [self tourArtworks];
    NSMutableArray *tours = [NSMutableArray arrayWithCapacity:[tourArtworks count]];
    for (CITourArtwork *tourArtwork in tourArtworks) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (uuid == %@)", tourArtwork.tourUuid];
        CITour *tour = [CITour MR_findFirstWithPredicate:predicate];
        if (tour != nil) {
            [tours addObject:tour];
        }
    }
    
    // Return tours sorted by newest
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
    return [tours sortedArrayUsingDescriptors:@[sort]];
}

- (NSArray*)media {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (artworkUuid == %@)", self.uuid];
    return [CIMedium MR_findAllWithPredicate:predicate];
}

- (NSArray*)images {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (artworkUuid == %@) AND (kind == %@)", self.uuid, @"image"];
    NSArray *results = [CIMedium MR_findAllWithPredicate:predicate];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES];
    return [results sortedArrayUsingDescriptors:@[sort]];
}

- (NSArray*)audio {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (artworkUuid == %@) AND (kind == %@)", self.uuid, @"audio"];
    NSArray *results = [CIMedium MR_findAllWithPredicate:predicate];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES];
    return [results sortedArrayUsingDescriptors:@[sort]];
}

- (NSArray*)videos {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (artworkUuid == %@) AND (kind == %@)", self.uuid, @"video"];
    NSArray *results = [CIMedium MR_findAllWithPredicate:predicate];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES];
    return [results sortedArrayUsingDescriptors:@[sort]];
}

@end