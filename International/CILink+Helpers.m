//
//  CILink+Helpers.m
//  International
//
//  Created by Dimitry Bentsionov on 8/4/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CILink+Helpers.h"

@implementation CILink (Helpers)

+ (NSString*)entityName {
    return NSStringFromClass(self);
}

+ (CILink*)findFirstOrCreateByAttribute:(NSString*)attribute withValue:(id)value usingData:(NSDictionary*)data {
    CILink *link = [CILink MR_findFirstByAttribute:attribute withValue:value];
    if (link == nil) {
        link = [CILink MR_createEntity];
    }
    
    // Parse the rest of the data and update the model object
    link.uuid = [data objectForKey:@"uuid"];
    link.createdAt = [CIData dateValueOrNilForKey:@"created_at" data:data];
    link.updatedAt = [CIData dateValueOrNilForKey:@"updated_at" data:data];
    link.deletedAt = [CIData dateValueOrNilForKey:@"deleted_at" data:data];
    
    link.title = [CIData objValueOrNilForKey:@"title" data:data];
    link.url = [CIData objValueOrNilForKey:@"url" data:data];
    link.position = [CIData objValueOrNilForKey:@"position" data:data];
    
    link.exhibitionUuid = [CIData objValueOrNilForKey:@"exhibition_uuid" data:data];
    link.artistUuid = [CIData objValueOrNilForKey:@"artist_uuid" data:data];
    
    // Mark as 'not changed'
    link.syncStatus = [NSNumber numberWithInteger:CISyncStatusNotChanged];
    
    return link;
}

- (NSDictionary*)toDictionary {
    return @{
             @"uuid" : self.uuid,
             @"created_at" : [CIData dateOrNSNull:self.createdAt],
             @"updated_at" : [CIData dateOrNSNull:self.updatedAt],
             @"deleted_at" : [CIData dateOrNSNull:self.deletedAt],
             
             @"title" : [CIData objOrNSNull:self.title],
             @"url" : [CIData objOrNSNull:self.url],
             @"position" : [CIData objOrNSNull:self.position],
             
             @"exhibition_uuid" : [CIData objOrNSNull:self.exhibitionUuid],
             @"artist_uuid" : [CIData objOrNSNull:self.artistUuid]
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

@end