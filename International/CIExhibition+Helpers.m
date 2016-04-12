//
//  CIExhibition+Helpers.m
//  International
//
//  Created by Dimitry Bentsionov on 7/8/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIExhibition+Helpers.h"

@implementation CIExhibition (Helpers)

+ (NSString*)entityName {
    return NSStringFromClass(self);
}

+ (CIExhibition*)findFirstOrCreateByAttribute:(NSString*)attribute withValue:(id)value usingData:(NSDictionary*)data {
    CIExhibition *exhibition = [CIExhibition MR_findFirstByAttribute:attribute withValue:value];
    if (exhibition == nil) {
        exhibition = [CIExhibition MR_createEntity];
        // Reset download status for new objects
        exhibition.bgDownloaded = @NO;
    } else {
        // If either of the dates is different, reset download status
        NSDate *iphoneUpdatedAt = [CIData dateValueOrNilForKey:@"bg_iphone_updated_at" data:data];
        NSDate *ipadUpdatedAt = [CIData dateValueOrNilForKey:@"bg_ipad_updated_at" data:data];
        if (([exhibition.bgIphoneUpdatedAt compare:iphoneUpdatedAt] != NSOrderedSame) ||
            ([exhibition.bgIpadUpdatedAt compare:ipadUpdatedAt] != NSOrderedSame)) {
            // Reset download status for new objects
            exhibition.bgDownloaded = @NO;
        }
    }
    
    // Parse the rest of the data and update the model object
    exhibition.uuid = [data objectForKey:@"uuid"];
    exhibition.createdAt = [CIData dateValueOrNilForKey:@"created_at" data:data];
    exhibition.updatedAt = [CIData dateValueOrNilForKey:@"updated_at" data:data];
    exhibition.deletedAt = [CIData dateValueOrNilForKey:@"deleted_at" data:data];

    exhibition.title = [CIData objValueOrNilForKey:@"title" data:data];
    exhibition.subtitle = [CIData objValueOrNilForKey:@"subtitle" data:data];
    exhibition.sponsor = [CIData objValueOrNilForKey:@"sponsor" data:data];
    exhibition.isLive = [CIData objValueOrNilForKey:@"is_live" data:data];
    exhibition.position = [CIData objValueOrNilForKey:@"position" data:data];
    
    exhibition.bgIphoneNormal = [CIData objValueOrNilForKey:@"bg_iphone_normal" data:data];
    exhibition.bgIphoneRetina = [CIData objValueOrNilForKey:@"bg_iphone_retina" data:data];
    exhibition.bgIphoneUpdatedAt = [CIData dateValueOrNilForKey:@"bg_iphone_updated_at" data:data];
    exhibition.bgIphoneFileSize = [CIData objValueOrNilForKey:@"bg_iphone_file_size" data:data];
    exhibition.bgIpadNormal = [CIData objValueOrNilForKey:@"bg_ipad_normal" data:data];
    exhibition.bgIpadRetina = [CIData objValueOrNilForKey:@"bg_ipad_retina" data:data];
    exhibition.bgIpadUpdatedAt = [CIData dateValueOrNilForKey:@"bg_ipad_updated_at" data:data];
    exhibition.bgIpadFileSize = [CIData objValueOrNilForKey:@"bg_ipad_file_size" data:data];
    
    // Mark as 'not changed'
    exhibition.syncStatus = [NSNumber numberWithInteger:CISyncStatusNotChanged];
    
    return exhibition;
}

+ (NSArray *)liveExhibitionUuids {
    NSMutableArray *liveExhibitionsUUIDs = [[NSMutableArray alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (isLive = YES)"];
    
    for (CIExhibition *exhibition in [CIExhibition MR_findAllWithPredicate:predicate]) {
        [liveExhibitionsUUIDs addObject:exhibition.uuid];
    }
    
    return liveExhibitionsUUIDs;
}

+ (CIExhibition*)randomLiveExhibition {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (isLive = YES)"];
    NSArray *exhibitions = [CIExhibition MR_findAllSortedBy:@"position" ascending:YES withPredicate:predicate];
    
    NSUInteger totalExhibitions = [exhibitions count];
    
    if (totalExhibitions == 0) {
        return nil;
    }
    
    NSUInteger randomNumber = arc4random() % totalExhibitions;
    
    return [exhibitions objectAtIndex:randomNumber];
}

- (NSDictionary*)toDictionary {
    return @{
             @"uuid" : self.uuid,
             @"created_at" : [CIData dateOrNSNull:self.createdAt],
             @"updated_at" : [CIData dateOrNSNull:self.updatedAt],
             @"deleted_at" : [CIData dateOrNSNull:self.deletedAt],
             
             @"title" : [CIData objOrNSNull:self.title],
             @"subtitle" : [CIData objOrNSNull:self.subtitle],
             @"sponsor" : [CIData objOrNSNull:self.sponsor],
             @"is_live" : [CIData objOrNSNull:self.isLive],
             @"position" : [CIData objOrNSNull:self.position],
             
             @"bg_iphone_normal" : [CIData objOrNSNull:self.bgIphoneNormal],
             @"bg_iphone_retina" : [CIData objOrNSNull:self.bgIphoneRetina],
             @"bg_iphone_updated_at" : [CIData dateOrNSNull:self.bgIphoneUpdatedAt],
             @"bg_iphone_file_size" : [CIData objOrNSNull:self.bgIphoneFileSize],
             @"bg_ipad_normal" : [CIData objOrNSNull:self.bgIpadNormal],
             @"bg_ipad_retina" : [CIData objOrNSNull:self.bgIpadRetina],
             @"bg_ipad_updated_at" : [CIData dateOrNSNull:self.bgIpadUpdatedAt],
             @"bg_ipad_file_size" : [CIData objOrNSNull:self.bgIpadFileSize]
             };
}

#pragma mark - Paths

- (NSString*)getDirectoryPath {
    // Local path structure: /Documents/Exhibitions/:uuid
    NSString *documentDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *path = [[documentDirectory stringByAppendingPathComponent:@"Media"] stringByAppendingPathComponent:self.uuid];
    return path;
}

- (NSString*)getBackgroundFilePath {
    // Local path structure: /Documents/Exhibitions/:uuid/bg.png (or bg@2x.png)
    NSString *fileName;
    if (IS_RETINA) {
        fileName = @"bg@2x.png";
    } else {
        fileName = @"bg.png";
    }
    NSString *documentDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *path = [[[documentDirectory stringByAppendingPathComponent:@"Media"]
                      stringByAppendingPathComponent:self.uuid]
                      stringByAppendingPathComponent:fileName];
    return path;
}

- (NSString*)getBlurredBackgroundFilePath {
    // Local path structure: /Documents/Exhibitions/:uuid/bg_blur.png (or bg_blur@2x.png)
    NSString *fileName;
    if (IS_RETINA) {
        fileName = @"bg_blur@2x.png";
    } else {
        fileName = @"bg_blur.png";
    }
    NSString *documentDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *path = [[[documentDirectory stringByAppendingPathComponent:@"Media"]
                       stringByAppendingPathComponent:self.uuid]
                      stringByAppendingPathComponent:fileName];
    return path;
}

#pragma mark - Relationships

- (NSArray*)artists {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (exhibitionUuid == %@)", self.uuid];
    NSArray *artists = [CIArtist MR_findAllWithPredicate:predicate];

    // Return results sorted
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
    return [artists sortedArrayUsingDescriptors:@[sort]];
}

- (NSArray*)artistArtworks {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (exhibitionUuid == %@)", self.uuid];
    return [CIArtistArtwork MR_findAllWithPredicate:predicate];
}

- (NSArray*)artworks {
    // Default sorting by code
    return [self artworksSortedBy:@"code" ascending:YES];
}

- (NSArray*)artworksSortedBy:(NSString *)sortedBy ascending:(BOOL)ascending {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (exhibitionUuid == %@)", self.uuid];
    return [CIArtwork MR_findAllSortedBy:sortedBy ascending:ascending withPredicate:predicate];
}

- (NSArray*)media {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (exhibitionUuid == %@)", self.uuid];
    return [CIMedium MR_findAllWithPredicate:predicate];
}

- (NSArray*)tours {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (exhibitionUuid == %@)", self.uuid];
    NSArray *tours = [CITour MR_findAllWithPredicate:predicate];

    // Return results sorted
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    return [tours sortedArrayUsingDescriptors:@[sort]];
}

- (NSArray*)tourArtworks {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (exhibitionUuid == %@)", self.uuid];
    return [CITourArtwork MR_findAllWithPredicate:predicate];
}

@end