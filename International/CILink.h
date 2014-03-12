//
//  CILink.h
//  International
//
//  Created by Dimitry Bentsionov on 8/5/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CILink : NSManagedObject

@property (nonatomic, retain) NSString * artistUuid;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * deletedAt;
@property (nonatomic, retain) NSString * exhibitionUuid;
@property (nonatomic, retain) NSNumber * syncStatus;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSNumber * position;

@end
