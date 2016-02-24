//
//  CIAppState.h
//  CMOA
//
//  Created by Dimitry Bentsionov on 2/3/14.
//  Copyright (c) 2014 Carnegie Museums. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CIAppState : NSObject

@property (nonatomic, strong) CIExhibition *currentExhibition;
@property (nonatomic, strong) CILocation *currentLocation;
@property (nonatomic, strong) NSArray *museumHours;
@property (nonatomic) BOOL isGodMode;

+ (CIAppState *)sharedAppState;

@end