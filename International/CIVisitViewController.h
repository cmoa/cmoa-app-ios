//
//  CIVisitViewController.h
//  International
//
//  Created by Dimitry Bentsionov on 8/6/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface CIVisitViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, MKMapViewDelegate> {
    IBOutlet UITableView *visitTableView;
    IBOutlet UIView *mapContainer;
    IBOutlet MKMapView *museumMapView;
    CLLocationCoordinate2D coord;
    
    // Google Maps detector
    BOOL hasGoogleMaps;
    BOOL pinDropped;
    
    // Open status
    BOOL isOpen;
    NSInteger dayOfWeek;
    NSArray *scheduledHours;
}

@end