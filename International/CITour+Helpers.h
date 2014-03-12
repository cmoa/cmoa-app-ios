//
//  CITour+Helpers.h
//  International
//
//  Created by Dimitry Bentsionov on 7/8/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CITour.h"

@interface CITour (Helpers)

+ (NSString*)entityName;
+ (CITour*)findFirstOrCreateByAttribute:(NSString*)attribute withValue:(id)value usingData:(NSDictionary*)data;
- (NSDictionary*)toDictionary;

#pragma mark - Relationships

- (CIExhibition*)exhibition;
- (NSArray*)tourArtworks;
- (NSArray*)artworks;

@end