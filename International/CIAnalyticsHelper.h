//
//  CIAnalyticsHelper.h
//  CMOA
//
//  Created by Dimitry Bentsionov on 9/3/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CIAnalyticsHelper : NSObject

+ (void)sendEvent:(NSString*)action;
+ (void)sendEvent:(NSString*)action withLabel:(NSString*)label;
+ (void)sendEvent:(NSString*)action withLabel:(NSString*)label withValue:(NSNumber*)value;

@end
