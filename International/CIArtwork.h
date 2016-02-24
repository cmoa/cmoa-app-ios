//
//  CIArtwork.h
//  CMOA
//
//  Created by Dimitry Bentsionov on 8/17/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CIArtwork : NSManagedObject

@property (nonatomic, retain) NSString * artistUuid;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * categoryUuid;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * deletedAt;
@property (nonatomic, retain) NSString * exhibitionUuid;
@property (nonatomic, retain) NSString * locationUuid;
@property (nonatomic, retain) NSString * shareUrl;
@property (nonatomic, retain) NSNumber * syncStatus;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSNumber * likes;
@property (nonatomic, retain) NSNumber * beaconUuid;

@end
