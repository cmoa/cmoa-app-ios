//
//  CICategory+Helpers.m
//  International
//
//  Created by Dimitry Bentsionov on 7/8/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CICategory+Helpers.h"

@implementation CICategory (Helpers)

+ (NSString*)entityName {
    return NSStringFromClass(self);
}

+ (CICategory*)findFirstOrCreateByAttribute:(NSString*)attribute withValue:(id)value usingData:(NSDictionary*)data {
    CICategory *category = [CICategory MR_findFirstByAttribute:attribute withValue:value];
    if (category == nil) {
        category = [CICategory MR_createEntity];
    }
    
    // Parse the rest of the data and update the model object
    category.uuid = [data objectForKey:@"uuid"];
    category.createdAt = [CIData dateValueOrNilForKey:@"created_at" data:data];
    category.updatedAt = [CIData dateValueOrNilForKey:@"updated_at" data:data];
    category.deletedAt = [CIData dateValueOrNilForKey:@"deleted_at" data:data];

    category.title = [CIData objValueOrNilForKey:@"title" data:data];
    
    // Mark as 'not changed'
    category.syncStatus = [NSNumber numberWithInteger:CISyncStatusNotChanged];
    
    return category;
}

- (NSDictionary*)toDictionary {
    return @{
             @"uuid" : self.uuid,
             @"created_at" : [CIData dateOrNSNull:self.createdAt],
             @"updated_at" : [CIData dateOrNSNull:self.updatedAt],
             @"deleted_at" : [CIData dateOrNSNull:self.deletedAt],

             @"title" : [CIData objOrNSNull:self.title]
             };
}

#pragma mark - Relationships

- (NSArray*)artworks {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (categoryUuid == %@)", self.uuid];
    NSArray *artworks = [CIArtwork MR_findAllWithPredicate:predicate];
    
    // Return results sorted
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES];
    return [artworks sortedArrayUsingDescriptors:@[sort]];
}

- (NSArray*)artworksInExhibition:(CIExhibition*)exhibition {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (categoryUuid == %@) AND (exhibitionUuid == %@)", self.uuid, exhibition.uuid];
    NSArray *artworks = [CIArtwork MR_findAllWithPredicate:predicate];
    
    // Return results sorted
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES];
    return [artworks sortedArrayUsingDescriptors:@[sort]];
}

- (NSArray*)artworksAtLocation:(CILocation*)location {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (categoryUuid == %@) AND (locationUuid == %@)", self.uuid, location.uuid];
    NSArray *artworks = [CIArtwork MR_findAllWithPredicate:predicate];
    
    // Return results sorted
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES];
    return [artworks sortedArrayUsingDescriptors:@[sort]];
}

@end