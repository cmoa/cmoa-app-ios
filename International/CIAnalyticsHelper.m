//
//  CIAnalyticsHelper.m
//  CMOA
//
//  Created by Dimitry Bentsionov on 9/3/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIAnalyticsHelper.h"

@implementation CIAnalyticsHelper

+ (void)sendEventWithCategory:(NSString*)category andAction:(NSString*)action {
    NSMutableDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:category
                                                                         action:action
                                                                          label:nil
                                                                          value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];
}

+ (void)sendEventWithCategory:(NSString*)category andAction:(NSString*)action andLabel:(NSString*)label {
    NSMutableDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:category
                                                                         action:action
                                                                          label:label
                                                                          value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];
}

+ (void)sendScreen:(NSString *)screenName {
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker set:kGAIScreenName
           value:screenName];
    
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    [[GAI sharedInstance] dispatch];
}


+ (void)sendEventWithCategory:(NSString*)category
                    andAction:(NSString*)action
                     andLabel:(NSString*)label
                    andValue:(NSNumber*)value {
    NSMutableDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:category
                                                                         action:action
                                                                          label:label
                                                                          value:value] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];
}

@end