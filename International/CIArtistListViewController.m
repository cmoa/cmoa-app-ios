//
//  CIViewController.m
//  International
//
//  Created by Dimitry Bentsionov on 7/3/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIArtistListViewController.h"
#import "CIArtistDetailViewController.h"
#import "CINavigationItem.h"
#import "CIExhibitionCell.h"
#import "CINavigationController.h"

@interface CIArtistListViewController ()

@end

@implementation CIArtistListViewController

@synthesize artists;
@synthesize parentMode;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Load artists
    if ([artists count] == 0) {
        [self loadArtists];
    }
    
    // Configure nav button
    CINavigationItem *navItem = (CINavigationItem *)self.navigationItem;
    [navItem setLeftBarButtonType:CINavigationItemLeftBarButtonTypeBack target:self action:@selector(navLeftButtonDidPress:)];
    
    // Tableview separator inset
    if ([artistTableView respondsToSelector:@selector(separatorInset)]) {
        artistTableView.separatorInset = UIEdgeInsetsZero;
    }
}

- (void)loadArtists {
    CIExhibition *exhibition = [CIAppState sharedAppState].currentExhibition;
    artists = exhibition.artists;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    NSIndexPath *selectedIndexPath = [artistTableView indexPathForSelectedRow];
    if (selectedIndexPath != nil) {
        [artistTableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    // Analytics
    [CIAnalyticsHelper sendEvent:@"ArtistList"];
}

- (void)navLeftButtonDidPress:(id)sender {
    if ([self.parentMode isEqualToString:@"artwork"]) {
        [self performSegueWithIdentifier:@"exitArtistListToArtworkDetail" sender:self];
    } else {
        [self performSegueWithIdentifier:@"exitArtistList" sender:self];
    }
}

- (IBAction)segueToArtistList:(UIStoryboardSegue *)segue {
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [artists count];
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
    [self performSegueWithIdentifier:@"showArtistDetail" sender:nil];
}

- (CIExhibitionCell *)getAndConfigureCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    // Init cell
    static NSString *CellIdentifier = @"CIExhibitionCell";
    CIExhibitionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CIExhibitionCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Find artist data
    CIArtist *artist = [artists objectAtIndex:indexPath.row];
    
    // Update cell
    cell.titleLabel.text = artist.name;
    NSString *country = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:artist.country];
    cell.subtitleLabel.text = [country uppercaseString];
    
    return cell;
}

#pragma mark - Transition

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showArtistDetail"]) {
        CIArtistDetailViewController *artistDetailViewController = (CIArtistDetailViewController *)segue.destinationViewController;
        NSIndexPath *selectedIndexPath = [artistTableView indexPathForSelectedRow];
        CIArtist *artist = [artists objectAtIndex:selectedIndexPath.row];
        artistDetailViewController.artist = artist;
        artistDetailViewController.artists = artists;
    }
}

@end
