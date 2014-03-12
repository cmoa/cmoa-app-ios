//
//  CIFileHelper.h
//  CMOA
//
//  Created by Dimitry Bentsionov on 9/6/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CIFileHelper : NSObject

+ (BOOL)addSkipBackupAttributeToItemAtURLstring:(NSString *)URLstring;

@end