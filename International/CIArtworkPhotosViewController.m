//
//  CIArtworkPhotosViewController.m
//  International
//
//  Created by Dimitry Bentsionov on 7/24/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIArtworkPhotosViewController.h"
#import "CINavigationItem.h"
#import "CIArtworkPhotoCell.h"
#import "CIArtworkDetailViewController.h"
#import "CINavigationController.h"

#define CELL_SPACING 8
#define CELL_INSET 15
#define CELL_IDENTIFIER @"CIArtworkPhotoCell"

@interface CIArtworkPhotosViewController ()

@end

@implementation CIArtworkPhotosViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Configure nav button
    if ([CIAppState sharedAppState].currentLocation == nil) {
        CINavigationItem *navItem = (CINavigationItem *)self.navigationItem;
        [navItem setLeftBarButtonType:CINavigationItemLeftBarButtonTypeBack target:self action:@selector(navLeftButtonDidPress:)];
    }
    
    // Load artworks & photos
    if ([CIAppState sharedAppState].currentLocation != nil) {
        CILocation *location = [CIAppState sharedAppState].currentLocation;
        self.navigationItem.title = location.name;
        
        artworks = [location liveArtworksSortedBy:@"title" ascending:YES];
    } else {
        CIExhibition *exhibition = [CIAppState sharedAppState].currentExhibition;
        self.navigationItem.title = exhibition.title;
        
        artworks = [exhibition artworksSortedBy:@"title" ascending:YES];
    }
  
    photos = [NSMutableArray arrayWithCapacity:[artworks count]];
    
    for (CIArtwork *artwork in artworks) {
      NSArray *artworkPhotos = [artwork images];
      if ([artworkPhotos count] == 0) {
        continue;
      }
      CIMedium *medium = [artworkPhotos objectAtIndex:0];
      [photos addObject:medium];
    }

    // Configure the waterfall
    CHTCollectionViewWaterfallLayout *photosCollectionLayout = (CHTCollectionViewWaterfallLayout *)photosCollectionView.collectionViewLayout;
    photosCollectionLayout.delegate = self;
    
    NSUInteger columnCount = 2;
   
    if (IS_IPAD) {
        columnCount = 3;
    }
    
    CGFloat viewWidth = self.navigationController.view.frame.size.width;
    cellWidth = (viewWidth - ((CELL_INSET * 2) + (CELL_SPACING * columnCount))) / columnCount;
    
    photosCollectionLayout.columnCount = columnCount;
    photosCollectionLayout.itemWidth = cellWidth;
    photosCollectionLayout.sectionInset = UIEdgeInsetsMake(CELL_INSET, CELL_INSET, CELL_INSET, CELL_INSET);
    [photosCollectionView registerClass:[CIArtworkPhotoCell class] forCellWithReuseIdentifier:CELL_IDENTIFIER];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)navLeftButtonDidPress:(id)sender {
    [self performSegueWithIdentifier:@"exitArtworkPhotos" sender:self];
}

- (IBAction)segueToArtworkPhotos:(UIStoryboardSegue *)segue {
    // Set cell to deselected
    NSArray *selectedItems = [photosCollectionView indexPathsForSelectedItems];
    NSIndexPath *selectedIndexPath = [selectedItems objectAtIndex:0];
    CIArtworkPhotoCell *cell = (CIArtworkPhotoCell *)[photosCollectionView cellForItemAtIndexPath:selectedIndexPath];
    [cell performSelectionAnimation:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    // Analytics
    [CIAnalyticsHelper sendScreen:@"Object Photos"];
}

#pragma mark - Collection view delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [photos count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Prepare the cell
    CIArtworkPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER
                                                                         forIndexPath:indexPath];
    
    // Find photo
    CIMedium *photo = [photos objectAtIndex:indexPath.row];
    cell.medium = photo;

    return cell;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(CHTCollectionViewWaterfallLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath {

    // Find photo
    CIMedium *photo = [photos objectAtIndex:indexPath.row];
    
    // Find the right height
    CGFloat ratio;
    if (IS_IPHONE) {
        ratio = [photo.width floatValue] / (float)cellWidth;
    } else {
        ratio = [photo.width floatValue] / (float)cellWidth;
    }

    return roundf([photo.height floatValue] / ratio);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showArtworkDetail" sender:nil];
    
    // Set cell to selected
    CIArtworkPhotoCell *cell = (CIArtworkPhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell performSelectionAnimation:YES];
}

#pragma mark - Transition

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showArtworkDetail"]) {
        // Find the artwork
        NSArray *selectedItems = [photosCollectionView indexPathsForSelectedItems];
        NSIndexPath *selectedIndexPath = [selectedItems objectAtIndex:0];
        CIMedium *photo = [photos objectAtIndex:selectedIndexPath.row];
        CIArtwork *artwork = photo.artwork;
        if (artwork != nil) {
            CIArtworkDetailViewController *artworkDetailViewController = (CIArtworkDetailViewController *)segue.destinationViewController;
            artworkDetailViewController.hidesBottomBarWhenPushed = YES;
            artworkDetailViewController.artworks = artworks;
            artworkDetailViewController.artwork = artwork;
            artworkDetailViewController.parentMode = @"photos";
        }
    }
}

@end