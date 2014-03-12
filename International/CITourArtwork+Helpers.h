//
//  CITourArtwork+Helpers.h
//  International
//
//  Created by Dimitry Bentsionov on 7/8/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CITourArtwork.h"

@interface CITourArtwork (Helpers)

+ (NSString*)entityName;
+ (CITourArtwork*)findFirstOrCreateByAttribute:(NSString*)attribute withValue:(id)value usingData:(NSDictionary*)data;
- (NSDictionary*)toDictionary;

#pragma mark - Relationships

- (CIExhibition*)exhibition;
- (CITour*)tour;
- (CIArtwork*)artwork;

@end