//
//  CIExhibitionListViewController.m
//  International
//
//  Created by Dimitry Bentsionov on 7/22/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIExhibitionListViewController.h"
#import "CINavigationController.h"
#import "CIExhibitionCell.h"
#import "CINavigationItem.h"

@interface CIExhibitionListViewController ()

@end

@implementation CIExhibitionListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Background
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Subscribe to sync notification
    if (IS_IPAD) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didFinishSyncNotification:)
                                                     name:@"DidFinishSync"
                                                   object:nil];
    }
    
    // Load exhibitions
    [self loadExhibitions];
    
    // Configure nav button
    if (IS_IPHONE) {
        CINavigationItem *navItem = (CINavigationItem *)self.navigationItem;
        [navItem setLeftBarButtonType:CINavigationItemLeftBarButtonTypeBack target:self action:@selector(navLeftButtonDidPress:)];
    } else {
        if ([exhibitions count] == 0) {
            exhibitionsTableView.hidden = YES;
        }
    }
    
    // Tableview separator inset
    if ([exhibitionsTableView respondsToSelector:@selector(separatorInset)]) {
        exhibitionsTableView.separatorInset = UIEdgeInsetsZero;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)navLeftButtonDidPress:(id)sender {
    [self performSegueWithIdentifier:@"exitExhibitionList" sender:self];
}

- (void)viewWillAppear:(BOOL)animated {
    NSIndexPath *selectedIndexPath = [exhibitionsTableView indexPathForSelectedRow];
    if (selectedIndexPath != nil) {
        [exhibitionsTableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    }
    
    // Show the navigation bar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // Clear any previously set current exhibitions
    CIAppState *appState = [CIAppState sharedAppState];
    appState.currentExhibition = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    // Analytics
    [CIAnalyticsHelper sendScreen:@"Exhibition List"];
}

- (void)dealloc {
    // Cleanup notification subscriptions
    if (IS_IPAD) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)loadExhibitions {
    // Are we in God mode?
    NSPredicate *predicate;
    if ([CIAppState sharedAppState].isGodMode == YES) {
        // Show all non-deleted exhibitions
        predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil)"];
    } else {
        // Show only exhibitions marked as LIVE
        predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (isLive = YES)"];
    }
    
    // Perform the search
    exhibitions = [CIExhibition MR_findAllSortedBy:@"position" ascending:YES withPredicate:predicate];
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [exhibitions count];
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
    // Find the exhibition
    CIExhibition *exhibition = [exhibitions objectAtIndex:indexPath.row];
    
    // Set the exhibition for the whole app
    CIAppState *appState = [CIAppState sharedAppState];
    appState.currentExhibition = exhibition;
    
    // Clear the current location if set
    appState.currentLocation = nil;
    
    [CIAnalyticsHelper sendEventWithCategory:@"Exhibition"
                                   andAction:@"Exhibition Viewed"
                                    andLabel:exhibition.title];

    // Show the exhibition detail controller
    [self performSegueWithIdentifier:@"showExhibitionDetail" sender:nil];
}

- (CIExhibitionCell *)getAndConfigureCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    // Init cell
    static NSString *CellIdentifier = @"CIExhibitionCell";
    CIExhibitionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CIExhibitionCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Find exhibition data
    CIExhibition *exhibition = [exhibitions objectAtIndex:indexPath.row];
    
    // Update cell
    cell.titleLabel.text = exhibition.title;
    cell.subtitleLabel.text = [exhibition.subtitle uppercaseString];
    
    return cell;
}

#pragma mark - Segue

- (IBAction)segueExitExhibitionDetail:(UIStoryboardSegue *)segue {
}

#pragma mark - Sync

- (void)didFinishSyncNotification:(NSNotification*)notification {
    // Load exhibitions
    [self loadExhibitions];

    // Show the table
    exhibitionsTableView.hidden = NO;
    [exhibitionsTableView reloadData];
}

@end