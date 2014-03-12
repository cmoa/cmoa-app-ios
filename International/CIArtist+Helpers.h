//
//  CIArtist+Helpers.h
//  International
//
//  Created by Dimitry Bentsionov on 7/4/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIArtist.h"

typedef enum {
    CISyncStatusNotChanged = 0,
    CISyncStatusQueued = 1
} CISyncStatus;

@interface CIArtist (Helpers)

+ (NSString*)entityName;
+ (CIArtist*)findFirstOrCreateByAttribute:(NSString*)attribute withValue:(id)value usingData:(NSDictionary*)data;
- (NSDictionary*)toDictionary;
- (NSString*)name;

#pragma mark - Relationships

- (CIExhibition*)exhibition;
- (NSArray*)artistArtworks;
- (NSArray*)artworks;
- (NSArray*)links;

@end