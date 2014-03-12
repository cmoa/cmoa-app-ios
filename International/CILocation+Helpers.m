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
             
             @"name" : [CIData objOrNSNull:self.name]
             };
}

#pragma mark - Relationships

- (NSArray*)artworks {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (locationUuid == %@)", self.uuid];
    return [CIArtwork MR_findAllSortedBy:@"code" ascending:YES withPredicate:predicate];
}

@end