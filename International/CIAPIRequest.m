//
//  CIAPIRequest.m
//  International
//
//  Created by Dimitry Bentsionov on 7/4/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "CIAPIRequest.h"
#import "UIDevice+IdentifierAddition.h"
#import "NSString+UrlEncode.h"
#import "NSData+Base64.h"

@implementation CIAPIRequest

@synthesize operation;

#pragma mark - Helpers

+ (NSData *)sha256:(NSData *)data {
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    if (CC_SHA256([data bytes], (int)[data length], hash)) {
        NSData *sha256 = [NSData dataWithBytes:hash length:CC_SHA256_DIGEST_LENGTH];
        return sha256;
    }
    return nil;
}

+ (NSString *)encodeStringUsingSHA256:(NSString *)data {
    NSData *dataData = [data dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    if (CC_SHA256([dataData bytes], (int)[dataData length], hash)) {
        NSData *sha256 = [NSData dataWithBytes:hash length:CC_SHA256_DIGEST_LENGTH];
        return [sha256 base64EncodedString];
    }
    return nil;
}

+ (NSString *)encodeStringUsingSHA256:(NSString *)data usingSalt:(NSString *)key {
    NSData *dataData = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, [keyData bytes], [keyData length], [dataData bytes], [dataData length], hash);
    NSData *HMAC = [NSData dataWithBytes:hash length:CC_SHA256_DIGEST_LENGTH];
    return [HMAC base64EncodedString];
}

+ (void)signRequest:(NSMutableURLRequest*)request
              token:(NSString*)token
             secret:(NSString*)secret
                url:(NSString*)url
             params:(NSDictionary*)params
          paramKeys:(NSArray*)keys {
    
    // Build long string to hash
    NSMutableString *hashable = [[NSMutableString alloc] init];
    [hashable appendFormat:@"%@:%@?", request.HTTPMethod, url];
    for (NSString *key in keys) {
        [hashable appendFormat:@"%@=%@&", key, [params objectForKey:key]];
    }
    
    // Add secret at the end
    [hashable appendFormat:@":%@", secret];
    
    // Hash it
    NSString *sodium = [CIAPIRequest encodeStringUsingSHA256:[NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]]];
    NSString *signature = [CIAPIRequest encodeStringUsingSHA256:hashable usingSalt:sodium];
    
    // Add as header to request
    [request setValue:signature forHTTPHeaderField:@"Authorization"];
    [request setValue:token forHTTPHeaderField:@"Token"];
    [request setValue:sodium forHTTPHeaderField:@"Sodium"];
}

- (void)apiPerformPostRequestWithURL:(NSString*)urlString
                            postData:(NSDictionary*)postData
                         signRequest:(BOOL)isRequestSigned
                             success:(CIAPIRequestSuccessBlock)success
                             failure:(CIAPIRequestFailureBlock)failure {
    
    NSURL *baseUrl = [NSURL URLWithString:API_BASE_URL];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseUrl];
    httpClient.stringEncoding = NSASCIIStringEncoding;
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:urlString parameters:postData];
    
    // Prepare for request signing
    if (isRequestSigned == YES) {
        // Parse GET parameters into hash
        NSMutableArray *urlElements = [NSMutableArray arrayWithArray:[urlString componentsSeparatedByString:@"?"]];
        NSString *urlPath = [urlElements objectAtIndex:0];
        [urlElements removeObjectAtIndex:0];
        NSString *queryPath = [urlElements componentsJoinedByString:@"?"]; // In case there's more than one ? (odd)
        NSArray *queryElements = [queryPath componentsSeparatedByString:@"&"];
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        for (NSString *element in queryElements) {
            NSArray *keyVal = [element componentsSeparatedByString:@"="];
            if (keyVal.count > 0) {
                NSString *key = [keyVal objectAtIndex:0];
                NSString *value = (keyVal.count == 2) ? [keyVal lastObject] : [NSNull null];
                [parameters setObject:value forKey:key];
            }
        }
        NSArray *paramKeys = [[parameters allKeys] sortedArrayUsingSelector:@selector(compare:)];
        NSString *fullUrlString = [NSString stringWithFormat:@"%@://%@%@%@", baseUrl.scheme, baseUrl.host, baseUrl.path, urlPath];
        
        // Sign the request
        NSString *settingsFilePath = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
        NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:settingsFilePath];
        [CIAPIRequest signRequest:request
                            token:[settings objectForKey:kCISettingsApiToken]
                           secret:[settings objectForKey:kCISettingsApiSecret]
                              url:fullUrlString
                           params:parameters
                        paramKeys:paramKeys
         ];
    }
    
    operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        // Check if status is false!
        if ([JSON respondsToSelector:@selector(objectForKey:)] && [JSON objectForKey:@"status"] != nil && [[JSON objectForKey:@"status"] boolValue] == NO) {
            if (failure) {
                failure(request, response, nil, JSON);
            }
            return;
        }
        // Success-case
        if (success) {
            success(request, response, JSON);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        // Failure-case
        if (failure) {
            failure(request, response, error, JSON);
        }
    }];
    
    [operation start];
}

#pragma mark - API methods

- (void)syncAll:(BOOL)syncAll
        success:(CIAPIRequestSuccessBlock)success
        failure:(CIAPIRequestFailureBlock)failure {
    
    // Data collections
    NSMutableDictionary *postData = [NSMutableDictionary dictionary];
    NSMutableArray *updatedAtDates = [NSMutableArray array];
    
    // Artists
    NSArray *artistObjs = [CIArtist MR_findByAttribute:@"syncStatus" withValue:[NSNumber numberWithInteger:CISyncStatusQueued]];
    NSMutableArray *artists = [NSMutableArray arrayWithCapacity:artistObjs.count];
    for (CIArtist *artist in artistObjs) {
        [artists addObject:[artist toDictionary]];
    }
    [postData setObject:artists forKey:@"artists"];
    CIArtist *artist = [CIArtist MR_findFirstOrderedByAttribute:@"updatedAt" ascending:NO];
    if (artist != nil) {
        [updatedAtDates addObject:artist.updatedAt];
    }
    
    // ArtistArtworks
    NSArray *artistArtworkObjs = [CIArtistArtwork MR_findByAttribute:@"syncStatus" withValue:[NSNumber numberWithInteger:CISyncStatusQueued]];
    NSMutableArray *artistArtworks = [NSMutableArray arrayWithCapacity:artistArtworkObjs.count];
    for (CIArtistArtwork *artistArtwork in artistArtworkObjs) {
        [artistArtworks addObject:[artistArtwork toDictionary]];
    }
    [postData setObject:artistArtworks forKey:@"artistArtworks"];
    CIArtistArtwork *artistArtwork = [CIArtistArtwork MR_findFirstOrderedByAttribute:@"updatedAt" ascending:NO];
    if (artistArtwork != nil) {
        [updatedAtDates addObject:artistArtwork.updatedAt];
    }
    
    // Artworks
    NSArray *artworkObjs = [CIArtwork MR_findByAttribute:@"syncStatus" withValue:[NSNumber numberWithInteger:CISyncStatusQueued]];
    NSMutableArray *artworks = [NSMutableArray arrayWithCapacity:artworkObjs.count];
    for (CIArtwork *artwork in artworkObjs) {
        [artworks addObject:[artwork toDictionary]];
    }
    [postData setObject:artworks forKey:@"artworks"];
    CIArtwork *artwork = [CIArtwork MR_findFirstOrderedByAttribute:@"updatedAt" ascending:NO];
    if (artwork != nil) {
        [updatedAtDates addObject:artwork.updatedAt];
    }
    
    // Categories
    NSArray *categoryObjs = [CICategory MR_findByAttribute:@"syncStatus" withValue:[NSNumber numberWithInteger:CISyncStatusQueued]];
    NSMutableArray *categories = [NSMutableArray arrayWithCapacity:categoryObjs.count];
    for (CICategory *category in categoryObjs) {
        [categories addObject:[category toDictionary]];
    }
    [postData setObject:categories forKey:@"categories"];
    CICategory *category = [CICategory MR_findFirstOrderedByAttribute:@"updatedAt" ascending:NO];
    if (category != nil) {
        [updatedAtDates addObject:category.updatedAt];
    }
    
    // Links
    NSArray *linkObjs = [CILink MR_findByAttribute:@"syncStatus" withValue:[NSNumber numberWithInteger:CISyncStatusQueued]];
    NSMutableArray *links = [NSMutableArray arrayWithCapacity:linkObjs.count];
    for (CILink *link in linkObjs) {
        [links addObject:[link toDictionary]];
    }
    [postData setObject:links forKey:@"links"];
    CILink *link = [CILink MR_findFirstOrderedByAttribute:@"updatedAt" ascending:NO];
    if (link != nil) {
        [updatedAtDates addObject:link.updatedAt];
    }
    
    // Locations
    NSArray *locationObjs = [CILocation MR_findByAttribute:@"syncStatus" withValue:[NSNumber numberWithInteger:CISyncStatusQueued]];
    NSMutableArray *locations = [NSMutableArray arrayWithCapacity:locationObjs.count];
    for (CILocation *location in locationObjs) {
        [locations addObject:[location toDictionary]];
    }
    [postData setObject:locations forKey:@"locations"];
    CILocation *location = [CILocation MR_findFirstOrderedByAttribute:@"updatedAt" ascending:NO];
    if (location != nil) {
        [updatedAtDates addObject:location.updatedAt];
    }
    
    // Exhibition
    NSArray *exhibitionObjs = [CIExhibition MR_findByAttribute:@"syncStatus" withValue:[NSNumber numberWithInteger:CISyncStatusQueued]];
    NSMutableArray *exhibitions = [NSMutableArray arrayWithCapacity:exhibitionObjs.count];
    for (CIExhibition *exhibition in exhibitionObjs) {
        [exhibitions addObject:[exhibition toDictionary]];
    }
    [postData setObject:exhibitions forKey:@"exhibitions"];
    CIExhibition *exhibition = [CIExhibition MR_findFirstOrderedByAttribute:@"updatedAt" ascending:NO];
    if (exhibition != nil) {
        [updatedAtDates addObject:exhibition.updatedAt];
    }
    
    // Media
    NSArray *mediumObjs = [CIMedium MR_findByAttribute:@"syncStatus" withValue:[NSNumber numberWithInteger:CISyncStatusQueued]];
    NSMutableArray *media = [NSMutableArray arrayWithCapacity:mediumObjs.count];
    for (CIMedium *medium in mediumObjs) {
        [media addObject:[medium toDictionary]];
    }
    [postData setObject:media forKey:@"media"];
    CIMedium *medium = [CIMedium MR_findFirstOrderedByAttribute:@"updatedAt" ascending:NO];
    if (medium != nil) {
        [updatedAtDates addObject:medium.updatedAt];
    }
    
    // Tours
    NSArray *tourObjs = [CITour MR_findByAttribute:@"syncStatus" withValue:[NSNumber numberWithInteger:CISyncStatusQueued]];
    NSMutableArray *tours = [NSMutableArray arrayWithCapacity:tourObjs.count];
    for (CITour *tour in tourObjs) {
        [tours addObject:[tour toDictionary]];
    }
    [postData setObject:tours forKey:@"tours"];
    CITour *tour = [CITour MR_findFirstOrderedByAttribute:@"updatedAt" ascending:NO];
    if (tour != nil) {
        [updatedAtDates addObject:tour.updatedAt];
    }
    
    // Tour Artworks
    NSArray *tourArtworkObjs = [CITourArtwork MR_findByAttribute:@"syncStatus" withValue:[NSNumber numberWithInteger:CISyncStatusQueued]];
    NSMutableArray *tourArtworks = [NSMutableArray arrayWithCapacity:tourArtworkObjs.count];
    for (CITourArtwork *tourArtwork in tourArtworkObjs) {
        [tourArtworks addObject:[tourArtwork toDictionary]];
    }
    [postData setObject:tourArtworks forKey:@"tourArtworks"];
    CITourArtwork *tourArtwork = [CITourArtwork MR_findFirstOrderedByAttribute:@"updatedAt" ascending:NO];
    if (tourArtwork != nil) {
        [updatedAtDates addObject:tourArtwork.updatedAt];
    }
    
    // Date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    // Find the latest updatedAt date
    NSDate *updatedAt;
    if ([updatedAtDates count] > 0) {
        NSArray *sortedUpdatedAtDates = [updatedAtDates sortedArrayUsingComparator:^NSComparisonResult(NSDate *date1, NSDate *date2) {
            return [date1 compare:date2] == NSOrderedAscending;
        }];
        updatedAt = [sortedUpdatedAtDates objectAtIndex:0];
    }
    
    // Sync all of the data?
    if (syncAll) {
        // Remove all exhibitions
        for (CIExhibition *exhibition in [CIExhibition MR_findAll]) {
            [exhibition MR_deleteEntity];
        }
        
        updatedAt = nil;
    }
    
    // API call
    NSString *url = [NSString stringWithFormat:@"/api/v2/sync?since=%@", updatedAt == nil ? @"" : [dateFormatter stringFromDate:updatedAt]];
//    NSLog(@"Sync: %@ : (POST: %@)", url, postData);
    [self apiPerformPostRequestWithURL:url postData:postData signRequest:NO success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//        NSLog(@"Sync response: %@", JSON);
        
        // Beacons
        for (NSDictionary *beaconData in [JSON objectForKey:@"beacons"]) {
            [CIBeacon findFirstOrCreateByAttribute:@"uuid" withValue:[beaconData objectForKey:@"uuid"] usingData:beaconData];
        }
        
        // Artists
        for (NSDictionary *artistData in [JSON objectForKey:@"artists"]) {
            [CIArtist findFirstOrCreateByAttribute:@"uuid" withValue:[artistData objectForKey:@"uuid"] usingData:artistData];
        }
        
        // ArtistArtworks
        for (NSDictionary *artistArtworkData in [JSON objectForKey:@"artistArtworks"]) {
            [CIArtistArtwork findFirstOrCreateByAttribute:@"uuid" withValue:[artistArtworkData objectForKey:@"uuid"] usingData:artistArtworkData];
        }
        
        // Artworks
        for (NSDictionary *artworkData in [JSON objectForKey:@"artwork"]) {
            [CIArtwork findFirstOrCreateByAttribute:@"uuid" withValue:[artworkData objectForKey:@"uuid"] usingData:artworkData];
        }
        
        // Categories
        for (NSDictionary *categoryData in [JSON objectForKey:@"categories"]) {
            [CICategory findFirstOrCreateByAttribute:@"uuid" withValue:[categoryData objectForKey:@"uuid"] usingData:categoryData];
        }
        
        // Links
        for (NSDictionary *linkData in [JSON objectForKey:@"links"]) {
            [CILink findFirstOrCreateByAttribute:@"uuid" withValue:[linkData objectForKey:@"uuid"] usingData:linkData];
        }
        
        // Locations
        for (NSDictionary *locationData in [JSON objectForKey:@"locations"]) {
            [CILocation findFirstOrCreateByAttribute:@"uuid" withValue:[locationData objectForKey:@"uuid"] usingData:locationData];
        }
        
        // Exhibitions
        for (NSDictionary *exhibitionData in [JSON objectForKey:@"exhibitions"]) {
            [CIExhibition findFirstOrCreateByAttribute:@"uuid" withValue:[exhibitionData objectForKey:@"uuid"] usingData:exhibitionData];
        }
        
        // Media
        for (NSDictionary *mediumData in [JSON objectForKey:@"media"]) {
            [CIMedium findFirstOrCreateByAttribute:@"uuid" withValue:[mediumData objectForKey:@"uuid"] usingData:mediumData];
        }
        
        // Tours
        for (NSDictionary *tourData in [JSON objectForKey:@"tours"]) {
            [CITour findFirstOrCreateByAttribute:@"uuid" withValue:[tourData objectForKey:@"uuid"] usingData:tourData];
        }
        
        // TourArtworks
        for (NSDictionary *tourArtworkData in [JSON objectForKey:@"tourArtworks"]) {
            [CITourArtwork findFirstOrCreateByAttribute:@"uuid" withValue:[tourArtworkData objectForKey:@"uuid"] usingData:tourArtworkData];
        }
        
        // Save the context
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success1, NSError *error) {
            if (error && failure) {
                failure(request, response, error, JSON);
            }
            if (error == nil && success) {
                success(request, response, JSON);
            }
        }];
    } failure:failure];
}

- (void)sync {
    [self syncAll:NO success:nil failure:nil];
}

- (void)syncAll {
    [self syncAll:YES success:nil failure:nil];
}

- (void)subscribeEmail:(NSString*)email
               success:(CIAPIRequestSuccessBlock)success
               failure:(CIAPIRequestFailureBlock)failure {
    
    // API call
    NSString *url = [NSString stringWithFormat:@"/api/v2/subscribe?email=%@", [email urlEncodedString]];
    [self apiPerformPostRequestWithURL:url
                              postData:nil
                           signRequest:YES
                               success:success
                               failure:failure];
}

@end