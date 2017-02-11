//
//  CILocation+Helpers.h
//  International
//
//  Created by Dimitry Bentsionov on 8/1/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CILocation.h"

@interface CILocation (Helpers)

+ (NSString*)entityName;
+ (CILocation*)findFirstOrCreateByAttribute:(NSString*)attribute withValue:(id)value usingData:(NSDictionary*)data;
- (NSDictionary*)toDictionary;

#pragma mark - Relationships

- (NSArray*)artworks;
- (NSArray*)artistArtworks;
- (NSArray*)artworksSortedBy:(NSString *)sortedBy ascending:(BOOL)ascending;
- (NSArray*)media;

- (NSArray*)liveArtworks;
- (NSArray*)liveArtworksSortedBy:(NSString *)sortedBy ascending:(BOOL)ascending;

@end