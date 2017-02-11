//
//  CITourDetailViewController.m
//  International
//
//  Created by Dimitry Bentsionov on 7/31/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CITourDetailViewController.h"
#import "CITourArtworkCell.h"
#import "CINavigationItem.h"
#import "CIArtworkDetailViewController.h"

@interface CITourDetailViewController ()

@end

@implementation CITourDetailViewController

@synthesize tour;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the title
    self.title = tour.title;
    
    // Set the description lbl
    lblDescription.attributedText = [CITextHelper attributedStringFromMarkdown:tour.body];
    
    // Get tour artwork
    artworks = tour.artworks;
    
    // Configure nav button
    CINavigationItem *navItem = (CINavigationItem *)self.navigationItem;
    [navItem setLeftBarButtonType:CINavigationItemLeftBarButtonTypeBack target:self action:@selector(navLeftButtonDidPress:)];
    
    // Seperation line
    descriptionContainer.backgroundColor = [UIColor colorFromHex:@"#cccccc"];
    
    // Tableview separator inset
    if ([artworkTableView respondsToSelector:@selector(separatorInset)]) {
        artworkTableView.separatorInset = UIEdgeInsetsZero;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    // Analytics
    [CIAnalyticsHelper sendScreen:@"Tour Detail"];
    [CIAnalyticsHelper sendEventWithCategory:@"Tour"
                                   andAction:@"Tour Viewed"
                                    andLabel:self.tour.title];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)navLeftButtonDidPress:(id)sender {
    [self performSegueWithIdentifier:@"exitTourDetail" sender:self];
}

- (IBAction)segueToTourDetail:(UIStoryboardSegue *)segue {
    // Set cell to deselected
    NSIndexPath *selectedIndexPath = [artworkTableView indexPathForSelectedRow];
    if (selectedIndexPath) {
        [artworkTableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    }
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [artworks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CITourArtworkCell *cell = [self getAndConfigureCellForTableView:tableView atIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Get cell
    CITourArtworkCell *cell = [self getAndConfigureCellForTableView:tableView atIndexPath:indexPath];
    
    // Calculate height
    return [cell getHeightInTableView:tableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showArtworkDetail" sender:nil];
}

- (CITourArtworkCell *)getAndConfigureCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    // Init cell
    static NSString *CellIdentifier = @"CITourArtworkCell";
    CITourArtworkCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CITourArtworkCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Find artwork data
    CIArtwork *artwork = [artworks objectAtIndex:indexPath.row];
    
    // Update cell
    cell.titleLabel.text = artwork.title;
    cell.subtitleLabel.text = [[CITextHelper artistsJoinedByComa:artwork.artists] uppercaseString];
    cell.sequenceLabel.text = [NSString stringWithFormat:@"%tu", (indexPath.row + 1)];
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
        artworkDetailViewController.parentMode = @"tours";
    }
}

@end