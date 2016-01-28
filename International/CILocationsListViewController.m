//
//  CILocationsListViewController.m
//  CMOA
//
//  Created by Ruben Niculcea on 1/25/16.
//  Copyright © 2016 Carnegie Museums. All rights reserved.
//

#import "CILocationsListViewController.h"

#import "CICategoryCell.h"
#import "CINavigationController.h"
#import "CINavigationItem.h"

@interface CILocationsListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *locationsTableView;
@property (nonatomic, retain) NSMutableArray *locations;

@end

@implementation CILocationsListViewController

@synthesize locations;
@synthesize locationsTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
  
    locations = [[NSMutableArray alloc] init];
    
    // Background
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Subscribe to sync notification
    if (IS_IPAD) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didFinishSyncNotification:)
                                                     name:@"DidFinishSync"
                                                   object:nil];
    }
  
    // Load artists
    if ([locations count] == 0) {
        [self loadLocations];
    }
  
    // Configure nav button
    if (IS_IPHONE) {
        CINavigationItem *navItem = (CINavigationItem *)self.navigationItem;
        [navItem setLeftBarButtonType:CINavigationItemLeftBarButtonTypeBack target:self action:@selector(navLeftButtonDidPress:)];
    } else {
        if ([locations count] == 0) {
            locationsTableView.hidden = YES;
        }
    }
  
    // Tableview separator inset
    if ([locationsTableView respondsToSelector:@selector(separatorInset)]) {
        locationsTableView.separatorInset = UIEdgeInsetsZero;
    }
}

- (void)loadLocations {
    for (CILocation *location in [CILocation MR_findAllSortedBy:@"name" ascending:TRUE]) {
        if ([[location liveArtworks] count] != 0) {
            [locations addObject:location];
        }
    }
}

- (void) viewWillAppear:(BOOL)animated {
    // Show the navigation bar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    // Analytics
    [CIAnalyticsHelper sendEvent:@"LocationsList"];
}

- (void)dealloc {
    // Cleanup notification subscriptions
    if (IS_IPAD) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)navLeftButtonDidPress:(id)sender {
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark - Segue

- (IBAction)segueToLocationList:(UIStoryboardSegue *)segue {
    [CIAppState sharedAppState].currentLocation = nil;
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [locations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Reuse CICategoryCell
    static NSString *CellIdentifier = @"CICategoryCell";
    CICategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CICategoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *locationName = [(CILocation *)locations[indexPath.item] name];
    cell.textLabel.text = locationName;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        [CIAppState sharedAppState].currentLocation = locations[indexPath.item];
        [self performSegueWithIdentifier:@"showRoomDetail" sender:self];
}

#pragma mark - Sync

- (void)didFinishSyncNotification:(NSNotification*)notification {
    // Load exhibitions
    [self loadLocations];
    
    // Show the table
    locationsTableView.hidden = NO;
    [locationsTableView reloadData];
}

@end
