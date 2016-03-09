//
//  CIMedium.h
//  CMOA
//
//  Created by Dimitry Bentsionov on 8/16/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CIMedium : NSManagedObject

@property (nonatomic, retain) NSString * artworkUuid;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * deletedAt;
@property (nonatomic, retain) NSString * exhibitionUuid;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSString * kind;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSNumber * syncStatus;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * alt;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * urlFull;
@property (nonatomic, retain) NSString * urlMedium;
@property (nonatomic, retain) NSString * urlSmall;
@property (nonatomic, retain) NSString * urlThumb;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSString * urlLarge;

@end
