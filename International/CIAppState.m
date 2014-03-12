//
//  CIAppState.m
//  CMOA
//
//  Created by Dimitry Bentsionov on 2/3/14.
//  Copyright (c) 2014 Carnegie Museums. All rights reserved.
//

#import "CIAppState.h"

@implementation CIAppState

static CIAppState *_sharedAppState = nil;

+ (CIAppState *)sharedAppState {
    @synchronized (self) {
        if (!_sharedAppState) {
            _sharedAppState = [[self alloc] init];
        }
    }
    return _sharedAppState;
}

- (id)init {
    self = [super init];
    if (self) {
        // Not in God mode by default
        self.isGodMode = NO;
    }
    return self;
}

@end