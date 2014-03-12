//
//  CIAnalyticsHelper.m
//  CMOA
//
//  Created by Dimitry Bentsionov on 9/3/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIAnalyticsHelper.h"

@implementation CIAnalyticsHelper

+ (void)sendEvent:(NSString*)action {
    NSMutableDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                                         action:action
                                                                          label:nil
                                                                          value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];
}

+ (void)sendEvent:(NSString*)action withLabel:(NSString*)label {
    NSMutableDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                                         action:action
                                                                          label:label
                                                                          value:nil] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];
}

+ (void)sendEvent:(NSString*)action withLabel:(NSString*)label withValue:(NSNumber*)value {
    NSMutableDictionary *event = [[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                                         action:action
                                                                          label:label
                                                                          value:value] build];
    [[GAI sharedInstance].defaultTracker send:event];
    [[GAI sharedInstance] dispatch];
}

@end