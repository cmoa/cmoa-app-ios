//
//  CILocationsListViewController.m
//  CMOA
//
//  Created by Ruben Niculcea on 1/25/16.
//  Copyright © 2016 Carnegie Museums. All rights reserved.
//

#import "CILocationsListViewController.h"

#import "CINavigationController.h"
#import "CINavigationItem.h"

@interface CILocationsListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSMutableArray *locations;

@end

@implementation CILocationsListViewController

@synthesize locations;

- (void)viewDidLoad {
  [super viewDidLoad];
  
  locations = [[NSMutableArray alloc] init];
  
  // Load artists
  if ([locations count] == 0) {
    [self loadLocations];
  }
  
  // Configure nav button
  CINavigationItem *navItem = (CINavigationItem *)self.navigationItem;
  [navItem setLeftBarButtonType:CINavigationItemLeftBarButtonTypeBack target:self action:@selector(navLeftButtonDidPress:)];
  
  // Tableview separator inset
//  if ([artistTableView respondsToSelector:@selector(separatorInset)]) {
//    artistTableView.separatorInset = UIEdgeInsetsZero;
//  }
}

- (void)loadLocations {
  for (CILocation *location in [CILocation MR_findAllSortedBy:@"name" ascending:TRUE]) {
      NSArray *artworks = [location artworksSortedBy:@"title" ascending:YES];
      
      if ([artworks count] == 0) {
          continue;
      }

    [locations addObject:location];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated {
  // Show the navigation bar
  [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
  // Analytics
  [CIAnalyticsHelper sendEvent:@"LocationsList"];
}

- (void)navLeftButtonDidPress:(id)sender {
  [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)segueToLocationList:(UIStoryboardSegue *)segue {
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [locations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [[UITableViewCell alloc] init];
  
  NSString *locationName = [(CILocation *)locations[indexPath.item] name];
  
  cell.textLabel.text = locationName;
  
  return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [CIAppState sharedAppState].currentLocation = locations[indexPath.item];
    [self performSegueWithIdentifier:@"showRoomDetail" sender:self];
}

@end
