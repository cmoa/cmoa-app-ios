//
//  CITour+Helpers.m
//  International
//
//  Created by Dimitry Bentsionov on 7/8/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CITour+Helpers.h"

@implementation CITour (Helpers)

+ (NSString*)entityName {
    return NSStringFromClass(self);
}

+ (CITour*)findFirstOrCreateByAttribute:(NSString*)attribute withValue:(id)value usingData:(NSDictionary*)data {
    CITour *tour = [CITour MR_findFirstByAttribute:attribute withValue:value];
    if (tour == nil) {
        tour = [CITour MR_createEntity];
    }
    
    // Parse the rest of the data and update the model object
    tour.uuid = [data objectForKey:@"uuid"];
    tour.createdAt = [CIData dateValueOrNilForKey:@"created_at" data:data];
    tour.updatedAt = [CIData dateValueOrNilForKey:@"updated_at" data:data];
    tour.deletedAt = [CIData dateValueOrNilForKey:@"deleted_at" data:data];

    tour.title = [CIData objValueOrNilForKey:@"title" data:data];
    tour.subtitle = [CIData objValueOrNilForKey:@"subtitle" data:data];
    tour.body = [CIData objValueOrNilForKey:@"body" data:data];
    
    tour.exhibitionUuid = [CIData objValueOrNilForKey:@"exhibition_uuid" data:data];
    
    // Mark as 'not changed'
    tour.syncStatus = [NSNumber numberWithInteger:CISyncStatusNotChanged];
    
    return tour;
}

- (NSDictionary*)toDictionary {
    return @{
             @"uuid" : self.uuid,
             @"created_at" : [CIData dateOrNSNull:self.createdAt],
             @"updated_at" : [CIData dateOrNSNull:self.updatedAt],
             @"deleted_at" : [CIData dateOrNSNull:self.deletedAt],

             @"title" : [CIData objOrNSNull:self.title],
             @"subtitle" : [CIData objOrNSNull:self.subtitle],
             @"description" : [CIData objOrNSNull:self.body],
             
             @"exhibition_uuid" : [CIData objOrNSNull:self.exhibitionUuid]
             };
}

#pragma mark - Relationships

- (CIExhibition*)exhibition {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (uuid == %@)", self.exhibitionUuid];
    return [CIExhibition MR_findFirstWithPredicate:predicate];
}

- (NSArray*)tourArtworks {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (tourUuid == %@)", self.uuid];
    NSArray *tourArtworks = [CITourArtwork MR_findAllWithPredicate:predicate];
    
    // Return results sorted
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES];
    return [tourArtworks sortedArrayUsingDescriptors:@[sort]];
}

- (NSArray*)artworks {
    NSArray *tourArtworks = [self tourArtworks];
    NSMutableArray *artworks = [NSMutableArray arrayWithCapacity:[tourArtworks count]];
    for (CITourArtwork *tourArtwork in tourArtworks) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (uuid == %@)", tourArtwork.artworkUuid];
        CIArtwork *artwork = [CIArtwork MR_findFirstWithPredicate:predicate];
        if (artwork != nil) {
            [artworks addObject:artwork];
        }
    }
    
    return artworks;
}

@end