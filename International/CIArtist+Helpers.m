//
//  CIArtist+Helpers.m
//  International
//
//  Created by Dimitry Bentsionov on 7/4/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIArtist+Helpers.h"

@implementation CIArtist (Helpers)

+ (NSString*)entityName {
    return NSStringFromClass(self);
}

+ (CIArtist*)findFirstOrCreateByAttribute:(NSString*)attribute withValue:(id)value usingData:(NSDictionary*)data {
    CIArtist *artist = [CIArtist MR_findFirstByAttribute:attribute withValue:value];
    if (artist == nil) {
        artist = [CIArtist MR_createEntity];
    }
    
    // Parse the rest of the data and update the model object
    artist.uuid = [data objectForKey:@"uuid"];
    artist.createdAt = [CIData dateValueOrNilForKey:@"created_at" data:data];
    artist.updatedAt = [CIData dateValueOrNilForKey:@"updated_at" data:data];
    artist.deletedAt = [CIData dateValueOrNilForKey:@"deleted_at" data:data];
    
    artist.firstName = [CIData objValueOrNilForKey:@"first_name" data:data];
    artist.lastName = [CIData objValueOrNilForKey:@"last_name" data:data];
    artist.country = [CIData objValueOrNilForKey:@"country" data:data];
    artist.code = [CIData objValueOrNilForKey:@"code" data:data];
    artist.bio = [CIData objValueOrNilForKey:@"bio" data:data];
    
    artist.exhibitionUuid = [CIData objValueOrNilForKey:@"exhibition_uuid" data:data];
    
    // Mark as 'not changed'
    artist.syncStatus = [NSNumber numberWithInteger:CISyncStatusNotChanged];
    
    return artist;
}

- (NSDictionary*)toDictionary {
    return @{
             @"uuid" : self.uuid,
             @"created_at" : [CIData dateOrNSNull:self.createdAt],
             @"updated_at" : [CIData dateOrNSNull:self.updatedAt],
             @"deleted_at" : [CIData dateOrNSNull:self.deletedAt],
             
             @"first_name" : [CIData objOrNSNull:self.firstName],
             @"last_name" : [CIData objOrNSNull:self.lastName],
             @"country" : [CIData objOrNSNull:self.country],
             @"code" : [CIData objOrNSNull:self.code],
             @"bio" : [CIData objOrNSNull:self.bio],

             @"exhibition_uuid" : [CIData objOrNSNull:self.exhibitionUuid]
             };
}

- (NSString*)name {
    // Avoid blank leading space if no first name
    if (self.firstName.length > 0) {
        return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
    } else {
        return self.lastName;
    }
}

#pragma mark - Relationships

- (CIExhibition*)exhibition {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (uuid == %@)", self.exhibitionUuid];
    return [CIExhibition MR_findFirstWithPredicate:predicate];
}

- (NSArray*)artistArtworks {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (artistUuid == %@)", self.uuid];
    return [CIArtistArtwork MR_findAllWithPredicate:predicate];
}

- (NSArray*)artworks {
    NSArray *artistArtworks = [self artistArtworks];
    NSMutableArray *artworks = [NSMutableArray arrayWithCapacity:[artistArtworks count]];
    for (CIArtistArtwork *artistArtwork in artistArtworks) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (uuid == %@)", artistArtwork.artworkUuid];
        CIArtwork *artwork = [CIArtwork MR_findFirstWithPredicate:predicate];
        if (artwork != nil) {
            [artworks addObject:artwork];
        }
    }
    
    // Return results sorted
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES];
    return [artworks sortedArrayUsingDescriptors:@[sort]];
}

- (NSArray*)links {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (artistUuid == %@)", self.uuid];
    return [CILink MR_findAllSortedBy:@"position" ascending:YES withPredicate:predicate];
}

@end