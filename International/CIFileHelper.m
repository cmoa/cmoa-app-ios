//
//  CIFileHelper.m
//  CMOA
//
//  Created by Dimitry Bentsionov on 9/6/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIFileHelper.h"

@implementation CIFileHelper

+ (BOOL)addSkipBackupAttributeToItemAtURLstring:(NSString *)URLstring {
    NSURL *URL = [[NSURL alloc] initFileURLWithPath:URLstring];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[URL path]] == NO) {
        return NO;
    }
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    if (!success) {
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

@end