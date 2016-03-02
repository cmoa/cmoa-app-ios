//
//  CIArtworkCategoryListViewController.m
//  CMOA
//
//  Created by Dimitry Bentsionov on 8/13/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CICategoryListViewController.h"
#import "CICategoryCell.h"
#import "CINavigationItem.h"
#import "CIArtworkListViewController.h"
#import "CINavigationController.h"

@interface CICategoryListViewController ()

@end

@implementation CICategoryListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CILocation *location;
    CIExhibition *exhibition;
    
    // Configure nav button
    if ([CIAppState sharedAppState].currentLocation == nil) {
        CINavigationItem *navItem = (CINavigationItem *)self.navigationItem;
        [navItem setLeftBarButtonType:CINavigationItemLeftBarButtonTypeBack target:self action:@selector(navLeftButtonDidPress:)];
    }
    
    // Load categories, then filter out those with 0 artworks!
    if ([CIAppState sharedAppState].currentLocation != nil) {
        location = [CIAppState sharedAppState].currentLocation;
        self.navigationItem.title = location.name;
    } else {
        exhibition = [CIAppState sharedAppState].currentExhibition;
        self.navigationItem.title = exhibition.title;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil)"];
    categories = [CICategory MR_findAllWithPredicate:predicate];

    NSMutableArray *tempCategories = [NSMutableArray arrayWithCapacity:[categories count]];
    for (CICategory *category in categories) {
        if (location != nil) {
            if ([[category liveArtworksAtLocation:location] count] > 0) {
                [tempCategories addObject:category];
            }
        } else {
            if ([[category artworksInExhibition:exhibition] count] > 0) {
                [tempCategories addObject:category];
            }
        }
    }
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    categories = [tempCategories sortedArrayUsingDescriptors:@[sort]];
    
    // Tableview separator inset
    if ([categoriesTableView respondsToSelector:@selector(separatorInset)]) {
        categoriesTableView.separatorInset = UIEdgeInsetsZero;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)navLeftButtonDidPress:(id)sender {
    [self performSegueWithIdentifier:@"exitToExhibitionDetail" sender:self];
}

- (void)viewWillAppear:(BOOL)animated {
    NSIndexPath *selectedIndexPath = [categoriesTableView indexPathForSelectedRow];
    if (selectedIndexPath != nil) {
        [categoriesTableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    // Analytics
    [CIAnalyticsHelper sendEvent:@"CategoryList"];
}

- (IBAction)segueToCategoryList:(UIStoryboardSegue *)segue {
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CICategoryCell";
    CICategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CICategoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Find category data
    CICategory *category = [categories objectAtIndex:indexPath.row];
    cell.textLabel.text = category.title;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showArtworkList" sender:nil];
}

#pragma mark - Transition

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showArtworkList"]) {
        // Find category
        NSIndexPath *indexPath = [categoriesTableView indexPathForSelectedRow];
        if (indexPath == nil) {
            return;
        }
        CICategory *category = [categories objectAtIndex:indexPath.row];
        if (category == nil) {
            return;
        }
        CIArtworkListViewController *artworkListViewController = (CIArtworkListViewController *)segue.destinationViewController;
        artworkListViewController.category = category;
        
        //TODO: Fix this
        CIExhibition *exhibition = [CIAppState sharedAppState].currentExhibition;
        artworkListViewController.artworks = [category artworksInExhibition:exhibition];
        artworkListViewController.parentMode = @"categoryList";
    }
}

@end