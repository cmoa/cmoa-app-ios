//
//  CICategory+Helpers.h
//  International
//
//  Created by Dimitry Bentsionov on 7/8/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CICategory.h"

@interface CICategory (Helpers)

+ (NSString*)entityName;
+ (CICategory*)findFirstOrCreateByAttribute:(NSString*)attribute withValue:(id)value usingData:(NSDictionary*)data;
- (NSDictionary*)toDictionary;

#pragma mark - Relationships

- (NSArray*)artworks;
- (NSArray*)artworksInExhibition:(CIExhibition*)exhibition;
- (NSArray*)artworksAtLocation:(CILocation*)location;
- (NSArray*)liveArtworksAtLocation:(CILocation*)location;

@end