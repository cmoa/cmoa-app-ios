//
//  CICategory.h
//  CMOA
//
//  Created by Dimitry Bentsionov on 2/19/14.
//  Copyright (c) 2014 Carnegie Museums. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CICategory : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * deletedAt;
@property (nonatomic, retain) NSNumber * syncStatus;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * uuid;

@end
