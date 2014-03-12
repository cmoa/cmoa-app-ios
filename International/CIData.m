//
//  CIData.m
//  International
//
//  Created by Dimitry Bentsionov on 7/8/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIData.h"

@implementation CIData

+ (id)objValueOrNilForKey:(NSString *)key data:(NSDictionary *)data {
    if ([data objectForKey:key] == (id)[NSNull null]) {
        return nil;
    } else {
        return [data objectForKey:key];
    }
}

+ (id)dateValueOrNilForKey:(NSString *)key data:(NSDictionary *)data {
    ISO8601DateFormatter *dateFormat = [[ISO8601DateFormatter alloc] init];
    if ([data objectForKey:key] == (id)[NSNull null]) {
        return nil;
    } else {
        return [dateFormat dateFromString:[data objectForKey:key]];
    }
}

+ (id)objOrNSNull:(id)obj {
    if (obj == nil) {
        return [NSNull null];
    } else {
        return obj;
    }
}

+ (id)dateOrNSNull:(id)obj {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];

    if (obj == nil) {
        return [NSNull null];
    } else {
        return [dateFormatter stringFromDate:obj];
    }
}

+ (CIExhibition *)getCurrentExhibition {
    return [CIExhibition MR_findFirstByAttribute:@"title" withValue:@"Carnegie International 2013"];
}

@end