//
//  CILocation.h
//  CMOA
//
//  Created by Dimitry Bentsionov on 2/19/14.
//  Copyright (c) 2014 Carnegie Museums. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CILocation : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * deletedAt;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * syncStatus;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSNumber * beaconUuid;

@end
