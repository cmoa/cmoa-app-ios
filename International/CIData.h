//
//  CIData.h
//  International
//
//  Created by Dimitry Bentsionov on 7/8/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CIExhibition;

@interface CIData : NSObject

+ (id)objValueOrNilForKey:(NSString *)key data:(NSDictionary *)data;
+ (id)dateValueOrNilForKey:(NSString *)key data:(NSDictionary *)data;
+ (id)objOrNSNull:(id)obj;
+ (id)dateOrNSNull:(id)obj;
+ (CIExhibition *)getCurrentExhibition;

@end
