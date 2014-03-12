//
//  CILink+Helpers.h
//  International
//
//  Created by Dimitry Bentsionov on 8/4/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CILink.h"

@interface CILink (Helpers)

+ (NSString*)entityName;
+ (CILink*)findFirstOrCreateByAttribute:(NSString*)attribute withValue:(id)value usingData:(NSDictionary*)data;
- (NSDictionary*)toDictionary;

#pragma mark - Relationships

- (CIExhibition*)exhibition;
- (CIArtist*)artist;

@end