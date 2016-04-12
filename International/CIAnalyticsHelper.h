//
//  CIAnalyticsHelper.h
//  CMOA
//
//  Created by Dimitry Bentsionov on 9/3/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CIAnalyticsHelper : NSObject

+ (void)sendScreen:(NSString *)screenName;

+ (void)sendEventWithCategory:(NSString*)category
                    andAction:(NSString*)action;

+ (void)sendEventWithCategory:(NSString*)category
                    andAction:(NSString*)action
                     andLabel:(NSString*)label;

+ (void)sendEventWithCategory:(NSString*)category
                    andAction:(NSString*)action
                     andLabel:(NSString*)label
                     andValue:(NSNumber*)value;

@end
