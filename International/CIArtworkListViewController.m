//
//  CIArtworkListViewController.m
//  International
//
//  Created by Dimitry Bentsionov on 7/8/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIArtworkListViewController.h"
#import "CIArtworkDetailViewController.h"
#import "CINavigationItem.h"
#import "CIExhibitionCell.h"
#import "CINavigationController.h"

@interface CIArtworkListViewController ()

@end

@implementation CIArtworkListViewController

@synthesize category;
@synthesize artworks;
@synthesize parentMode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Load artworks
    if ([self.artworks count] == 0) {
        [self loadArtwork];
    }

    // Configure nav button
    if ([CIAppState sharedAppState].currentLocation == nil || [parentMode isEqual:@"categoryList"]) {
        CINavigationItem *navItem = (CINavigationItem *)self.navigationItem;
        [navItem setLeftBarButtonType:CINavigationItemLeftBarButtonTypeBack target:self action:@selector(navLeftButtonDidPress:)];
    }
    
    // Category list child?
    if (self.category != nil) {
        self.title = self.category.title;
    }
    
    // Tableview separator inset
    if ([artworkTableView respondsToSelector:@selector(separatorInset)]) {
        artworkTableView.separatorInset = UIEdgeInsetsZero;
    }
}

- (void)loadArtwork {
    if ([CIAppState sharedAppState].currentLocation != nil) {
        CILocation *location = [CIAppState sharedAppState].currentLocation;
        self.navigationItem.title = location.name;
        
        artworks = location.liveArtworks;
    } else {
        CIExhibition *exhibition = [CIAppState sharedAppState].currentExhibition;
        self.navigationItem.title = exhibition.title;
        
        artworks = exhibition.artworks;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    NSIndexPath *selectedIndexPath = [artworkTableView indexPathForSelectedRow];
    if (selectedIndexPath != nil) {
        [artworkTableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    // Analytics
    [CIAnalyticsHelper sendScreen:@"Object List"];
}

- (void)navLeftButtonDidPress:(id)sender {
    if ([self.parentMode isEqualToString:@"artistDetail"]) {
        [self performSegueWithIdentifier:@"exitToArtistDetail" sender:self];
    } else if ([self.parentMode isEqualToString:@"categoryList"]) {
        [self performSegueWithIdentifier:@"exitToCategoryList" sender:self];
    } else if ([self.parentMode isEqualToString:@"visit"]) {
        [self performSegueWithIdentifier:@"exitToVisit" sender:self];
    } else {
        [self performSegueWithIdentifier:@"exitArtworkList" sender:self];
    }
}

- (IBAction)segueToArtworkList:(UIStoryboardSegue *)segue {
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [artworks count];
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
    [self performSegueWithIdentifier:@"showArtworkDetail" sender:nil];
}

- (CIExhibitionCell *)getAndConfigureCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    // Init cell
    static NSString *CellIdentifier = @"CIExhibitionCell";
    CIExhibitionCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CIExhibitionCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Find artwork data
    CIArtwork *artwork = [artworks objectAtIndex:indexPath.row];
    
    // Update cell
    cell.titleLabel.text = artwork.title;
    cell.subtitleLabel.text = [[CITextHelper artistsJoinedByComa:artwork.artists] uppercaseString];
    BOOL hasAudio = [artwork.audio count] > 0;
    BOOL hasVideo = [artwork.videos count] > 0;
    [cell setIdentificationWithAudio:hasAudio withVideo:hasVideo];
    
    return cell;
}

#pragma mark - Transition

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showArtworkDetail"]) {
        CIArtworkDetailViewController *artworkDetailViewController = (CIArtworkDetailViewController *)segue.destinationViewController;
        NSIndexPath *selectedIndexPath = [artworkTableView indexPathForSelectedRow];
        CIArtwork *artwork = [artworks objectAtIndex:selectedIndexPath.row];
        artworkDetailViewController.hidesBottomBarWhenPushed = YES;
        artworkDetailViewController.artworks = artworks;
        artworkDetailViewController.artwork = artwork;
        artworkDetailViewController.parentMode = @"artworks";
    }
}

@end