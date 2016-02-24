//
//  CIAPIRequest.h
//  International
//
//  Created by Dimitry Bentsionov on 7/4/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

#define API_BASE_URL @"http://ec2-52-91-205-57.compute-1.amazonaws.com/"
#define API_TOKEN    @"207b0977eb0be992898c7cf102f1bd8b"
#define API_SECRET   @"5b2d5ba341d2ded69a4d6cef387951ad"

typedef void (^CIAPIHoursRequestSuccessBlock) (NSArray *hours);
typedef void (^CIAPIRequestSuccessBlock) (NSURLRequest *request, NSHTTPURLResponse *response, id JSON);
typedef void (^CIAPIRequestFailureBlock) (NSURLRequest* request, NSHTTPURLResponse* response, NSError* error, id JSON);

@interface CIAPIRequest : NSObject {
    AFJSONRequestOperation *operation;
}

@property (nonatomic, retain) AFJSONRequestOperation *operation;

#pragma mark - API Methods

- (void)syncAll:(BOOL)syncAll
        success:(CIAPIRequestSuccessBlock)success
        failure:(CIAPIRequestFailureBlock)failure;

- (void)sync;

- (void)syncAll;

- (void)getWeeksHours:(CIAPIHoursRequestSuccessBlock)success
              failure:(CIAPIRequestFailureBlock)failure;

- (void)subscribeEmail:(NSString*)email
               success:(CIAPIRequestSuccessBlock)success
               failure:(CIAPIRequestFailureBlock)failure;

@end
