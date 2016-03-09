//
//  CIMedium+Helpers.m
//  International
//
//  Created by Dimitry Bentsionov on 7/8/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIMedium+Helpers.h"

@implementation CIMedium (Helpers)

+ (NSString*)entityName {
    return NSStringFromClass(self);
}

+ (CIMedium*)findFirstOrCreateByAttribute:(NSString*)attribute withValue:(id)value usingData:(NSDictionary*)data {
    CIMedium *medium = [CIMedium MR_findFirstByAttribute:attribute withValue:value];
    if (medium == nil) {
        medium = [CIMedium MR_createEntity];
    }
    
    // Parse the rest of the data and update the model object
    medium.uuid = [data objectForKey:@"uuid"];
    medium.createdAt = [CIData dateValueOrNilForKey:@"created_at" data:data];
    medium.updatedAt = [CIData dateValueOrNilForKey:@"updated_at" data:data];
    medium.deletedAt = [CIData dateValueOrNilForKey:@"deleted_at" data:data];

    medium.title = [CIData objValueOrNilForKey:@"title" data:data];
    medium.alt = [CIData objValueOrNilForKey:@"alt" data:data];
    medium.kind = [CIData objValueOrNilForKey:@"kind" data:data];
    medium.position = [CIData objValueOrNilForKey:@"position" data:data];
    medium.width = [CIData objValueOrNilForKey:@"width" data:data];
    medium.height = [CIData objValueOrNilForKey:@"height" data:data];
    medium.urlThumb = [CIData objValueOrNilForKey:@"urlThumb" data:data];
    medium.urlFull = [CIData objValueOrNilForKey:@"urlFull" data:data];
    medium.urlSmall = [CIData objValueOrNilForKey:@"urlSmall" data:data];
    medium.urlMedium = [CIData objValueOrNilForKey:@"urlMedium" data:data];
    medium.urlLarge = [CIData objValueOrNilForKey:@"urlLarge" data:data];
    
    medium.exhibitionUuid = [CIData objValueOrNilForKey:@"exhibition_uuid" data:data];
    medium.artworkUuid = [CIData objValueOrNilForKey:@"artwork_uuid" data:data];
    
    // Mark as 'not changed'
    medium.syncStatus = [NSNumber numberWithInteger:CISyncStatusNotChanged];
    
    return medium;
}

- (NSDictionary*)toDictionary {
    return @{
             @"uuid" : self.uuid,
             @"created_at" : [CIData dateOrNSNull:self.createdAt],
             @"updated_at" : [CIData dateOrNSNull:self.updatedAt],
             @"deleted_at" : [CIData dateOrNSNull:self.deletedAt],

             @"title" : [CIData objOrNSNull:self.title],
             @"alt" : [CIData objOrNSNull:self.alt],
             @"kind" : [CIData objOrNSNull:self.kind],
             @"position" : [CIData objOrNSNull:self.position],
             @"width" : [CIData objOrNSNull:self.width],
             @"height" : [CIData objOrNSNull:self.height],
             @"urlThumb" : [CIData objOrNSNull:self.urlThumb],
             @"urlFull" : [CIData objOrNSNull:self.urlFull],
             @"urlSmall" : [CIData objOrNSNull:self.urlSmall],
             @"urlMedium" : [CIData objOrNSNull:self.urlMedium],
             @"urlLarge" : [CIData objOrNSNull:self.urlLarge],
             
             @"exhibition_uuid" : [CIData objOrNSNull:self.exhibitionUuid],
             @"artwork_uuid" : [CIData objOrNSNull:self.artworkUuid]
             };
}

#pragma mark - Paths

+ (NSString*)getDirectoryPathForUrl:(NSString*)url {
    // Local path structure: /Documents/Media/:uuid
    NSString *documentDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSArray *urlBits = [url componentsSeparatedByString:@"/"];
    NSString *path = [[documentDirectory stringByAppendingPathComponent:@"Media"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [urlBits objectAtIndex:[urlBits count] - 2]]];
    return path;
}

+ (NSString*)getFilePathForUrl:(NSString*)url {
    // Local path structure: /Documents/Media/:uuid/:style.:extension
    NSString *documentDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSArray *urlBits = [url componentsSeparatedByString:@"/"];
    NSString *path = [[[documentDirectory stringByAppendingPathComponent:@"Media"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [urlBits objectAtIndex:[urlBits count] - 2]]] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [urlBits objectAtIndex:[urlBits count] - 1]]];
    return path;
}

#pragma mark - Relationships
//
- (CIExhibition*)exhibition {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (uuid == %@)", self.exhibitionUuid];
    return [CIExhibition MR_findFirstWithPredicate:predicate];
}

- (CIArtwork*)artwork {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (uuid == %@)", self.artworkUuid];
    return [CIArtwork MR_findFirstWithPredicate:predicate];
}

@end