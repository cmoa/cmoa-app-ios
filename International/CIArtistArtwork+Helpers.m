//
//  CIArtistArtwork+Helpers.m
//  CMOA
//
//  Created by Dimitry Bentsionov on 8/30/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIArtistArtwork+Helpers.h"

@implementation CIArtistArtwork (Helpers)

+ (NSString*)entityName {
    return NSStringFromClass(self);
}

+ (CIArtistArtwork*)findFirstOrCreateByAttribute:(NSString*)attribute withValue:(id)value usingData:(NSDictionary*)data {
    CIArtistArtwork *artistArtwork = [CIArtistArtwork MR_findFirstByAttribute:attribute withValue:value];
    if (artistArtwork == nil) {
        artistArtwork = [CIArtistArtwork MR_createEntity];
    }
    
    // Parse the rest of the data and update the model object
    artistArtwork.uuid = [data objectForKey:@"uuid"];
    artistArtwork.createdAt = [CIData dateValueOrNilForKey:@"created_at" data:data];
    artistArtwork.updatedAt = [CIData dateValueOrNilForKey:@"updated_at" data:data];
    artistArtwork.deletedAt = [CIData dateValueOrNilForKey:@"deleted_at" data:data];
    
    artistArtwork.exhibitionUuid = [CIData objValueOrNilForKey:@"exhibition_uuid" data:data];
    artistArtwork.artistUuid = [CIData objValueOrNilForKey:@"artist_uuid" data:data];
    artistArtwork.artworkUuid = [CIData objValueOrNilForKey:@"artwork_uuid" data:data];
    
    // Mark as 'not changed'
    artistArtwork.syncStatus = [NSNumber numberWithInteger:CISyncStatusNotChanged];
    
    return artistArtwork;
}

- (NSDictionary*)toDictionary {
    return @{
             @"uuid" : self.uuid,
             @"created_at" : [CIData dateOrNSNull:self.createdAt],
             @"updated_at" : [CIData dateOrNSNull:self.updatedAt],
             @"deleted_at" : [CIData dateOrNSNull:self.deletedAt],

             @"exhibition_uuid" : [CIData objOrNSNull:self.exhibitionUuid],
             @"artist_uuid" : [CIData objOrNSNull:self.artistUuid],
             @"artwork_uuid" : [CIData objOrNSNull:self.artworkUuid]
             };
}

#pragma mark - Relationships

- (CIExhibition*)exhibition {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (uuid == %@)", self.exhibitionUuid];
    return [CIExhibition MR_findFirstWithPredicate:predicate];
}

- (CIArtist*)artist {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (uuid == %@)", self.artistUuid];
    return [CIArtist MR_findFirstWithPredicate:predicate];
}

- (CIArtwork*)artwork {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (uuid == %@)", self.artworkUuid];
    return [CIArtwork MR_findFirstWithPredicate:predicate];
}

@end