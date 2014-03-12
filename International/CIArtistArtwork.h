//
//  CIArtistArtwork.h
//  CMOA
//
//  Created by Dimitry Bentsionov on 12/23/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CIArtistArtwork : NSManagedObject

@property (nonatomic, retain) NSString * artistUuid;
@property (nonatomic, retain) NSString * artworkUuid;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * deletedAt;
@property (nonatomic, retain) NSNumber * syncStatus;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSString * exhibitionUuid;

@end
