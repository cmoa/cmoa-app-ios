//
//  CIArtistArtwork+Helpers.h
//  CMOA
//
//  Created by Dimitry Bentsionov on 8/30/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIArtistArtwork.h"

@class CIArtwork;

@interface CIArtistArtwork (Helpers)

+ (NSString*)entityName;
+ (CIArtistArtwork*)findFirstOrCreateByAttribute:(NSString*)attribute withValue:(id)value usingData:(NSDictionary*)data;
- (NSDictionary*)toDictionary;

#pragma mark - Relationships

- (CIExhibition*)exhibition;
- (CIArtist*)artist;
- (CIArtwork*)artwork;

@end
