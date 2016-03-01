//
//  CIArtwork+Helpers.h
//  International
//
//  Created by Dimitry Bentsionov on 7/8/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIArtwork.h"

@class CICategory;
@class CILocation;

@interface CIArtwork (Helpers)

+ (NSString*)entityName;
+ (CIArtwork*)findFirstOrCreateByAttribute:(NSString*)attribute withValue:(id)value usingData:(NSDictionary*)data;
- (NSDictionary*)toDictionary;
+ (NSArray*)findAllByRecommendedInExhibition:(CIExhibition *)exhibition;

#pragma mark - Relationships

+ (CIArtwork *)artworkWithBeacon:(CIBeacon *)beacon;

- (CIExhibition*)exhibition;
- (NSArray*)artistArtworks;
- (NSArray*)artists;
- (CILocation*)location;
- (CICategory*)category;
- (NSArray*)tourArtworks;
- (NSArray*)tours;
- (NSArray*)media;
- (NSArray*)images;
- (NSArray*)audio;
- (NSArray*)videos;

@end