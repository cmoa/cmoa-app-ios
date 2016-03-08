//
//  CIVisitViewController.m
//  International
//
//  Created by Dimitry Bentsionov on 8/6/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIVisitViewController.h"
#import "CINavigationItem.h"
#import "CIHoursCell.h"
#import "CIMapAnnotation.h"
#import "CIAPIRequest.h"
#import "CIArtworkListViewController.h"
#import "CIBrowserViewController.h"

#define CMOA_VISIT_URL @"http://www.carnegiemuseums.org/interior.php?pageID=36"
#define METERS_PER_MILE 1609.344
#define kCellHeight 60.0f

@interface CIVisitViewController ()

@end

@implementation CIVisitViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Default
        pinDropped = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Configure nav button
    if (IS_IPHONE) {
        CINavigationItem *navItem = (CINavigationItem *)self.navigationItem;
        [navItem setLeftBarButtonType:CINavigationItemLeftBarButtonTypeBack target:self action:@selector(navLeftButtonDidPress:)];
    }
    
    NSArray *museumHours = [CIAppState sharedAppState].museumHours;
    
    if (museumHours != nil) {
        [self isMuseumOpen:museumHours];
        scheduledHours = [self returnScheduledHours:museumHours];
    } else {
        scheduledHours = nil;
    }
    
    if (scheduledHours == nil) {
        hoursTableHeightConstraint.constant = kCellHeight * 2;
    } else {
        NSInteger maxHoursRows = 5;
        
        if (IS_IPAD) {
            maxHoursRows = 6;
        } else if (IS_SHORT_IPHONE) {
            maxHoursRows = 4;
        }
            
        if ([scheduledHours count] > maxHoursRows) {
            hoursTableHeightConstraint.constant = 300;
        } else {
            hoursTableHeightConstraint.constant = kCellHeight * ([scheduledHours count] + 1);
        }
    }
    
    // Configure map container
    mapContainer.backgroundColor = [UIColor colorFromHex:@"#cccccc"];
    
    // Map gesture
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mapDidTouch:)];
    [museumMapView addGestureRecognizer:gesture];
    
    // Google Maps detect
    hasGoogleMaps = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]];
    
    // Tableview separator inset
    if ([visitTableView respondsToSelector:@selector(separatorInset)]) {
        visitTableView.separatorInset = UIEdgeInsetsZero;
    }
}

- (void)isMuseumOpen:(NSArray *)museumHours {
    // Calculate open/close status
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"America/New_York"]];
    [dateFormatter setDateFormat:@"c"];
    dayOfWeek = [[dateFormatter stringFromDate:[NSDate date]] integerValue];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:[NSDate date]];
    [components setTimeZone:[NSTimeZone timeZoneWithName:@"America/New_York"]];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    
    NSDictionary *currentDay = museumHours[dayOfWeek-1];
    
    if ([currentDay[@"open"] isEqualToString:@"closed"] || [currentDay[@"close"] isEqualToString:@"closed"]) {
        isOpen = false;
    } else {
        NSArray *opensComponents = [currentDay[@"open"] componentsSeparatedByString:@":"];
        NSInteger currentDayOpensHour = [opensComponents[0] integerValue];
        NSInteger currentDayOpensMinute = [opensComponents[1] integerValue];
        
        NSArray *closesComponents = [currentDay[@"close"] componentsSeparatedByString:@":"];
        NSInteger currentDayClosesHour = [closesComponents[0] integerValue];
        NSInteger currentDayClosesMinute = [closesComponents[1] integerValue];
        
        if (hour == currentDayOpensHour && minute >= currentDayOpensMinute) {
            isOpen = true;
        } else if (hour == currentDayClosesHour && minute < currentDayClosesMinute) {
            isOpen = true;
        } else if (hour >= currentDayOpensHour && hour < currentDayClosesHour) {
            isOpen = true;
        }
    }
}

- (NSArray *)returnScheduledHours:(NSArray *)museumHours {
    NSMutableArray *bundledHours = [[NSMutableArray alloc] init];
    [museumHours enumerateObjectsUsingBlock:^(NSDictionary *hours, NSUInteger idx, BOOL *stop)
     {
         if ([bundledHours count] == 0) {
             NSMutableArray *container = [[NSMutableArray alloc] initWithObjects:hours, nil];
             [bundledHours addObject:container];
             
         } else {
             for (int i = 0; i < [bundledHours count]; i++) {
                 if ([bundledHours[i][0][@"open"] isEqualToString:hours[@"open"]] &&
                     [bundledHours[i][0][@"close"] isEqualToString:hours[@"close"]]) {
                     [bundledHours[i] addObject:hours];
                     break;
                 }
                 
                 if (([bundledHours count] - 1) == i) {
                     NSMutableArray *container = [[NSMutableArray alloc] initWithObjects:hours, nil];
                     [bundledHours addObject:container];
                     break;
                 }
             }
         }
     }];
    
    return bundledHours;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)navLeftButtonDidPress:(id)sender {
    [self performSegueWithIdentifier:@"exitVisit" sender:self];
}

- (void)viewWillAppear:(BOOL)animated {
    // Show the navigation bar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // Deselect table
    NSIndexPath *selectedIndexPath = [visitTableView indexPathForSelectedRow];
    if (selectedIndexPath != nil) {
        [visitTableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    // Analytics
    [CIAnalyticsHelper sendScreen:@"Hours and Location"];
    
    if (pinDropped == NO) {
        pinDropped = YES;
        
        // Load map
        coord = CLLocationCoordinate2DMake(40.4432, -79.9497);
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coord, 0.3f*METERS_PER_MILE, 0.3f*METERS_PER_MILE);
        [museumMapView setRegion:viewRegion animated:NO];
        [UIView animateWithDuration:0.3f animations:^{
            museumMapView.alpha = 1.0f;
        }];
        
        // Annotate the map (drop pin)
        CIMapAnnotation *annotation = [[CIMapAnnotation alloc] init];
        annotation.coordinate = coord;
        annotation.title = @"Carnegie Museum of Art";
        annotation.subtitle = @"4400 Forbes Ave, Pittsburgh, PA 15213";
        [museumMapView addAnnotation:annotation];
    }
}

- (IBAction)segueToVisit:(UIStoryboardSegue *)segue {
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (scheduledHours == nil) {
        return 2;
    } else {
        return [scheduledHours count] + 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CIHoursCell";
    CIHoursCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CIHoursCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (scheduledHours == nil) {
        if (indexPath.row == 1) {
            cell.titleLabel.text = @"Visit Carnegie Museums";
            cell.subtitleLabel.text = [@"For more visitor information and holiday hours" uppercaseString];
        } else {
            cell.titleLabel.text = @"No internet connection";
            cell.subtitleLabel.text = [@"Please connect to the internet to see hours" uppercaseString];
        }
        
    } else {
        if (indexPath.row == [scheduledHours count]) {
            cell.titleLabel.text = @"Visit Carnegie Museums";
            cell.subtitleLabel.text = [@"For more visitor information and holiday hours" uppercaseString];
        } else {
            NSMutableArray *daysArray = [[NSMutableArray alloc] init];
            for (NSDictionary *hours in scheduledHours[indexPath.row]) {
                [daysArray addObject:hours[@"day"]];
            }
            
            NSMutableString *title = [[NSMutableString alloc] init];
            
            if ([daysArray count] > 3) {
                [title appendString:[[daysArray subarrayWithRange:NSMakeRange(0, 3)] componentsJoinedByString: @", "]];
                [title appendFormat:@",\n%@", [[daysArray subarrayWithRange:NSMakeRange(3, [daysArray count] - 3)]componentsJoinedByString: @", "]];
                
                cell.titleLabel.numberOfLines = 2;
            } else {
                title = (NSMutableString *)[daysArray componentsJoinedByString: @", "];
            }
            
            cell.titleLabel.text = title;
            cell.subtitleLabel.text = [[cell titleForHours:scheduledHours[indexPath.row][0]] uppercaseString];
            [cell setCellAsHours];
            
            NSArray *daysOfTheWeek = @[@"Sunday",
                                       @"Monday",
                                       @"Tuesday",
                                       @"Wednesday",
                                       @"Thursday",
                                       @"Friday",
                                       @"Saturday"];
            
            for (NSDictionary *hours in scheduledHours[indexPath.row]) {
                if ((dayOfWeek - 1) == [daysOfTheWeek indexOfObject:hours[@"day"]]) {
                    [cell setTodayAsOpen:isOpen];
                    break;
                }
            }
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (scheduledHours == nil) {
        if (indexPath.row == 1) {
            [self performSegueWithIdentifier:@"showBrowser" sender:self];
        }
    } else {
        if (indexPath.row == [scheduledHours count]) {
            [self performSegueWithIdentifier:@"showBrowser" sender:self];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (scheduledHours == nil) {
        return (indexPath.row == 1);
    } else {
        return (indexPath.row == [scheduledHours count]);
    }
}

#pragma mark - Action Sheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // What action?
    switch (buttonIndex) {
            // Open iOS Maps
        case 0: {
            MKPlacemark *location = [[MKPlacemark alloc] initWithCoordinate:coord addressDictionary:nil];
            MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:location];
            
            NSMutableDictionary *launchOptions = [[NSMutableDictionary alloc] init];
            [launchOptions setObject:MKLaunchOptionsDirectionsModeDriving forKey:MKLaunchOptionsDirectionsModeKey];
            
            [item openInMapsWithLaunchOptions:launchOptions];
        }
            break;
            
            // Open Google Maps
        case 1: {
            if (hasGoogleMaps) {
                NSString *googleMapsURL = [NSString stringWithFormat:@"comgooglemaps://?center=%.4f,%.4f&zoom=17", coord.latitude, coord.longitude];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapsURL]];
            }
        }
            break;
    }
}

#pragma mark - Map touch / delegate

- (void)mapDidTouch:(UITapGestureRecognizer *)gesture {
    // Open action sheet
    UIActionSheet *popupQuery;
    if (hasGoogleMaps) {
        popupQuery = [[UIActionSheet alloc] initWithTitle:@"4400 Forbes Ave, Pittsburgh, PA 15213"
                                                 delegate:self
                                        cancelButtonTitle:@"Cancel"
                                   destructiveButtonTitle:nil
                                        otherButtonTitles:@"Open in Apple Maps", @"Open in Google Maps", nil];
    } else {
        popupQuery = [[UIActionSheet alloc] initWithTitle:@"4400 Forbes Ave, Pittsburgh, PA 15213"
                                                 delegate:self
                                        cancelButtonTitle:@"Cancel"
                                   destructiveButtonTitle:nil
                                        otherButtonTitles:@"Open in Maps", nil];
    }

    popupQuery.tag = 1;
    if (IS_IPHONE) {
        [popupQuery showInView:self.view];
    } else {
        [popupQuery showFromRect:mapContainer.frame inView:self.view animated:YES];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    static NSString* museumAnnotationIdentifier = @"museumAnnotationIdentifier";
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:museumAnnotationIdentifier];
    if (!pinView) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:museumAnnotationIdentifier];
        pinView.pinColor = MKPinAnnotationColorRed;
        pinView.animatesDrop = YES;
    }
    return pinView;
}

#pragma mark - Transition

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showBrowser"]) {
        CIBrowserViewController *browserViewController = (CIBrowserViewController *)segue.destinationViewController;
        browserViewController.parentMode = @"visit";
        browserViewController.viewTitle = @"Carnegie Museums";
        browserViewController.url = CMOA_VISIT_URL;
    }
}

@end