//
//  CIMapAnnotation.h
//  CMOA
//
//  Created by Dimitry Bentsionov on 8/15/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CIMapAnnotation : NSObject <MKAnnotation> {
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@end