//
//  CITourArtwork+Helpers.m
//  International
//
//  Created by Dimitry Bentsionov on 7/8/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CITourArtwork+Helpers.h"

@implementation CITourArtwork (Helpers)

+ (NSString*)entityName {
    return NSStringFromClass(self);
}

+ (CITourArtwork*)findFirstOrCreateByAttribute:(NSString*)attribute withValue:(id)value usingData:(NSDictionary*)data {
    CITourArtwork *tourArtwork = [CITourArtwork MR_findFirstByAttribute:attribute withValue:value];
    if (tourArtwork == nil) {
        tourArtwork = [CITourArtwork MR_createEntity];
    }
    
    // Parse the rest of the data and update the model object
    tourArtwork.uuid = [data objectForKey:@"uuid"];
    tourArtwork.createdAt = [CIData dateValueOrNilForKey:@"created_at" data:data];
    tourArtwork.updatedAt = [CIData dateValueOrNilForKey:@"updated_at" data:data];
    tourArtwork.deletedAt = [CIData dateValueOrNilForKey:@"deleted_at" data:data];

    tourArtwork.position = [CIData objValueOrNilForKey:@"position" data:data];
    
    tourArtwork.exhibitionUuid = [CIData objValueOrNilForKey:@"exhibition_uuid" data:data];
    tourArtwork.tourUuid = [CIData objValueOrNilForKey:@"tour_uuid" data:data];
    tourArtwork.artworkUuid = [CIData objValueOrNilForKey:@"artwork_uuid" data:data];
    
    // Mark as 'not changed'
    tourArtwork.syncStatus = [NSNumber numberWithInteger:CISyncStatusNotChanged];
    
    return tourArtwork;
}

- (NSDictionary*)toDictionary {
    return @{
             @"uuid" : self.uuid,
             @"created_at" : [CIData dateOrNSNull:self.createdAt],
             @"updated_at" : [CIData dateOrNSNull:self.updatedAt],
             @"deleted_at" : [CIData dateOrNSNull:self.deletedAt],

             @"position" : [CIData objOrNSNull:self.position],
             
             @"exhibition_uuid" : [CIData objOrNSNull:self.exhibitionUuid],
             @"tour_uuid" : [CIData objOrNSNull:self.tourUuid],
             @"artwork_uuid" : [CIData objOrNSNull:self.artworkUuid]
             };
}

#pragma mark - Relationships

- (CIExhibition*)exhibition {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (uuid == %@)", self.exhibitionUuid];
    return [CIExhibition MR_findFirstWithPredicate:predicate];
}

- (CITour*)tour {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (uuid == %@)", self.tourUuid];
    return [CITour MR_findFirstWithPredicate:predicate];
}

- (CIArtwork*)artwork {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (uuid == %@)", self.artworkUuid];
    return [CIArtwork MR_findFirstWithPredicate:predicate];
}

@end