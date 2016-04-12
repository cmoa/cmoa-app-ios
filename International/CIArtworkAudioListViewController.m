//
//  CIArtworkAudioListViewController.m
//  International
//
//  Created by Dimitry Bentsionov on 8/1/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIArtworkAudioListViewController.h"
#import "CIAudioCell.h"
#import "CINavigationItem.h"

@interface CIArtworkAudioListViewController ()

@end

@implementation CIArtworkAudioListViewController

@synthesize artwork;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Load the media
    NSMutableArray *filteredMedia = [NSMutableArray arrayWithArray:self.artwork.audio];
    [filteredMedia removeObjectAtIndex:0]; // Removes main audio that was on the previous view controller
    media = [NSArray arrayWithArray:filteredMedia];
    
    // Configure nav button
    CINavigationItem *navItem = (CINavigationItem *)self.navigationItem;
    [navItem setLeftBarButtonType:CINavigationItemLeftBarButtonTypeBack target:self action:@selector(navLeftButtonDidPress:)];
    
    // Set the title
    self.title = self.artwork.title;
    
    // Tableview separator inset
    if ([audioTableView respondsToSelector:@selector(separatorInset)]) {
        audioTableView.separatorInset = UIEdgeInsetsZero;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    // Analytics
    [CIAnalyticsHelper sendScreen:@"Object Audio List"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)navLeftButtonDidPress:(id)sender {
    [self performSegueWithIdentifier:@"showArtworkDetail" sender:self];
}

- (void)dealloc {
    for (int i=0; i<[media count]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        CIAudioCell *cell = (CIAudioCell *)[audioTableView cellForRowAtIndexPath:indexPath];
        [cell.audioView cleanUp];
    }
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [media count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CIAudioCell";
    CIAudioCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CIAudioCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Find audio data
    CIMedium *medium = [media objectAtIndex:indexPath.row];
    cell.medium = medium;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 83.0f;
    return 50.0f;
}

@end