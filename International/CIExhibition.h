//
//  CIExhibition.h
//  CMOA
//
//  Created by Dimitry Bentsionov on 12/10/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CIExhibition : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * deletedAt;
@property (nonatomic, retain) NSNumber * isLive;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSString * sponsor;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSNumber * syncStatus;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSString * bgIphoneNormal;
@property (nonatomic, retain) NSString * bgIpadRetina;
@property (nonatomic, retain) NSDate * bgIphoneUpdatedAt;
@property (nonatomic, retain) NSDate * bgIpadUpdatedAt;
@property (nonatomic, retain) NSString * bgIpadNormal;
@property (nonatomic, retain) NSString * bgIphoneRetina;
@property (nonatomic, retain) NSNumber * bgIpadFileSize;
@property (nonatomic, retain) NSNumber * bgIphoneFileSize;
@property (nonatomic, retain) NSNumber * bgDownloaded;

@end
