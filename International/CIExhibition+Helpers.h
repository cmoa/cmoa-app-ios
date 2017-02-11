//
//  CIExhibition+Helpers.h
//  International
//
//  Created by Dimitry Bentsionov on 7/8/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIExhibition.h"

@interface CIExhibition (Helpers)

+ (NSString*)entityName;
+ (CIExhibition*)findFirstOrCreateByAttribute:(NSString*)attribute withValue:(id)value usingData:(NSDictionary*)data;
- (NSDictionary*)toDictionary;
+ (CIExhibition*)randomLiveExhibition;

+ (NSArray*)liveExhibitionUuids;

#pragma mark - Paths

- (NSString*)getDirectoryPath;
- (NSString*)getBackgroundFilePath;
- (NSString*)getBlurredBackgroundFilePath;

#pragma mark - Relationships

- (NSArray*)artists;
- (NSArray*)artistArtworks;
- (NSArray*)artworks;
- (NSArray*)artworksSortedBy:(NSString *)sortedBy ascending:(BOOL)ascending;
- (NSArray*)media;
- (NSArray*)tours;
- (NSArray*)tourArtworks;

@end