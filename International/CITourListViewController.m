//
//  CITourListViewController.m
//  International
//
//  Created by Dimitry Bentsionov on 7/31/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CITourListViewController.h"
#import "CIExhibitionCell.h"
#import "CINavigationItem.h"
#import "CITourDetailViewController.h"
#import "CINavigationController.h"

@interface CITourListViewController ()

@end

@implementation CITourListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Load the tours
    CIExhibition *exhibition = [CIAppState sharedAppState].currentExhibition;
    tours = exhibition.tours;
    
    // Configure nav button
    CINavigationItem *navItem = (CINavigationItem *)self.navigationItem;
    [navItem setLeftBarButtonType:CINavigationItemLeftBarButtonTypeBack target:self action:@selector(navLeftButtonDidPress:)];
    
    // Tableview separator inset
    if ([toursTableView respondsToSelector:@selector(separatorInset)]) {
        toursTableView.separatorInset = UIEdgeInsetsZero;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    // Analytics
    [CIAnalyticsHelper sendEvent:@"TourList"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)navLeftButtonDidPress:(id)sender {
    [self performSegueWithIdentifier:@"exitTourList" sender:self];
}

- (IBAction)segueToTourList:(UIStoryboardSegue *)segue {
    // Set cell to deselected
    NSIndexPath *selectedIndexPath = [toursTableView indexPathForSelectedRow];
    if (selectedIndexPath) {
        [toursTableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    }
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [tours count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CIExhibitionCell *cell = [self getAndConfigureCellForTableView:tableView atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Get cell
    CIExhibitionCell *cell = [self getAndConfigureCellForTableView:tableView atIndexPath:indexPath];
    
    // Calculate height
    return [cell getHeightInTableView:tableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showTourDetail" sender:nil];
}

- (CIExhibitionCell *)getAndConfigureCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    // Init cell
    static NSString *CellIdentifier = @"CIExhibitionCell";
    CIExhibitionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CIExhibitionCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    CITour *tour = [tours objectAtIndex:indexPath.row];
    cell.titleLabel.text = tour.title;
    cell.subtitleLabel.text = [tour.subtitle uppercaseString];
    
    return cell;
}

#pragma mark - Transition

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showTourDetail"]) {
        CITourDetailViewController *tourDetailViewController = (CITourDetailViewController *)segue.destinationViewController;
        NSIndexPath *selectedIndexPath = [toursTableView indexPathForSelectedRow];
        
        CITour *tour = [tours objectAtIndex:selectedIndexPath.row];
        tourDetailViewController.tour = tour;

    }
}

@end