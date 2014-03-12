//
//  CIMedium+Helpers.h
//  International
//
//  Created by Dimitry Bentsionov on 7/8/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIMedium.h"

@interface CIMedium (Helpers)

+ (NSString*)entityName;
+ (CIMedium*)findFirstOrCreateByAttribute:(NSString*)attribute withValue:(id)value usingData:(NSDictionary*)data;
- (NSDictionary*)toDictionary;

#pragma mark - Paths

+ (NSString*)getDirectoryPathForUrl:(NSString*)url;
+ (NSString*)getFilePathForUrl:(NSString*)url;

#pragma mark - Relationships

- (CIExhibition*)exhibition;
- (CIArtwork*)artwork;

@end