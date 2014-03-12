//
//  CIArtist.h
//  CMOA
//
//  Created by Dimitry Bentsionov on 8/30/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CIArtist : NSManagedObject

@property (nonatomic, retain) NSString * bio;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * deletedAt;
@property (nonatomic, retain) NSString * exhibitionUuid;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * syncStatus;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * uuid;

@end
