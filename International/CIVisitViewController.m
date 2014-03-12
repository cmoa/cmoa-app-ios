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
#import "CIArtworkListViewController.h"
#import "CIBrowserViewController.h"

#define CMOA_VISIT_URL @"http://cmoa.org/visit"
#define METERS_PER_MILE 1609.344

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
        [navItem setLeftBarButtonType:CINavigationItemLeftBarButtonTypeMenu target:self action:@selector(navLeftButtonDidPress:)];
    }
    
    // Calculate open/close status
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"America/New_York"]];
    [dateFormatter setDateFormat:@"c"];
    dayOfWeek = [[dateFormatter stringFromDate:[NSDate date]] integerValue];

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit) fromDate:[NSDate date]];
    [components setTimeZone:[NSTimeZone timeZoneWithName:@"America/New_York"]];
    NSInteger hour = [components hour];
    
    switch (dayOfWeek) {
        case 1: // Sunday
            isOpen = (hour >= 12 && hour < 17); // 12pm - 5pm
            break;
        case 2: // Monday
        case 4: // Wednesday
        case 6: // Friday
        case 7: // Saturday
            isOpen = (hour >= 10 && hour < 17); // 10am - 5pm
            break;
        case 3: // Tuesday
            isOpen = NO; // Closed
            break;
        case 5: // Thursday
            isOpen = (hour >= 10 && hour < 20); // 10am - 8pm
            break;
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

    // Load bookmarked artworks
    [self loadBookmarkedArtworks];
}

- (void)viewDidAppear:(BOOL)animated {
    // Analytics
    [CIAnalyticsHelper sendEvent:@"MyVisit"];

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

#pragma mark - Bookmarked Artworks

- (void)loadBookmarkedArtworks {
    NSArray *likedArtworks = [[NSUserDefaults standardUserDefaults] arrayForKey:kCIArtworksLiked];
    NSMutableArray *tempBookmarked = [NSMutableArray arrayWithCapacity:[likedArtworks count]];
    if (likedArtworks != nil) {
        for (NSString *artworkUuid in likedArtworks) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (uuid == %@)", artworkUuid];
            CIArtwork *artwork = [CIArtwork MR_findFirstWithPredicate:predicate];
            if (artwork != nil) {
                [tempBookmarked addObject:artwork];
            }
        }
    }
    
    // Sort bookmarked artworks
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"code" ascending:YES];
    bookmarked = [tempBookmarked sortedArrayUsingDescriptors:@[sort]];
    [visitTableView reloadData];
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CIHoursCell";
    CIHoursCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CIHoursCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Fill the rows
    switch (indexPath.row) {
        case 0: {
            cell.titleLabel.text = @"Tuesday – Saturday";
            cell.subtitleLabel.text = [@"10 am – 5 pm" uppercaseString];
            [cell setCellAsHours];
            if ((dayOfWeek != 1 && dayOfWeek != 5) && (dayOfWeek >= 3 && dayOfWeek <= 7)) {
                [cell setTodayAsOpen:isOpen];
            }
        }
            break;

        case 1: {
            cell.titleLabel.text = @"Thursday";
            cell.subtitleLabel.text = [@"10 am – 8 pm" uppercaseString];
            [cell setCellAsHours];
            if (dayOfWeek == 5) {
                [cell setTodayAsOpen:isOpen];
            }
        }
            break;
        
        case 2: {
            cell.titleLabel.text = @"Sunday";
            cell.subtitleLabel.text = [@"Noon – 5 pm" uppercaseString];
            [cell setCellAsHours];
            if (dayOfWeek == 1) {
                [cell setTodayAsOpen:isOpen];
            }
        }
            break;
            
        case 3: {
            cell.titleLabel.text = @"Visit CMOA.ORG";
            cell.subtitleLabel.text = [@"For more visitor information and holiday hours" uppercaseString];
        }
            break;
            
        case 4: {
            cell.titleLabel.text = @"My Bookmarked Artworks";
            if ([bookmarked count] != 1) {
                cell.subtitleLabel.text = [[NSString stringWithFormat:@"%i artworks", [bookmarked count]] uppercaseString];
            } else {
                cell.subtitleLabel.text = [@"1 artwork" uppercaseString];
            }
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {
        [self performSegueWithIdentifier:@"showBrowser" sender:self];
    } else if (indexPath.row == 4) {
        if ([bookmarked count] > 0) {
            [self performSegueWithIdentifier:@"showArtworkList" sender:self];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Bookmarked Artwork"
                                                                message:@"Tap thumbs up on your favorite artworks to bookmark them for the future."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            [visitTableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.row >= 3);
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
    if ([segue.identifier isEqualToString:@"showArtworkList"]) {
        CIArtworkListViewController *artworkListViewController = (CIArtworkListViewController *)segue.destinationViewController;
        artworkListViewController.artworks = bookmarked;
        artworkListViewController.parentMode = @"visit";
    } else if ([segue.identifier isEqualToString:@"showBrowser"]) {
        CIBrowserViewController *browserViewController = (CIBrowserViewController *)segue.destinationViewController;
        browserViewController.parentMode = @"visit";
        browserViewController.viewTitle = @"CMOA.org";
        browserViewController.url = CMOA_VISIT_URL;
    }
}

@end