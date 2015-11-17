//
//  CIArtistDetailViewController.m
//  International
//
//  Created by Dimitry Bentsionov on 7/9/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CIArtistDetailViewController.h"
#import "CINavigationItem.h"
#import "CIArtworkListViewController.h"
#import "CIArtworkDetailViewController.h"
#import "CILinkCell.h"
#import "CIBrowserViewController.h"

#define METERS_PER_MILE 1609.344
#define LINKS_CELL_HEIGHT 50

@interface CIArtistDetailViewController () {
    CGFloat pinchScale;
}

@end

@implementation CIArtistDetailViewController

@synthesize artist;
@synthesize artists;
@synthesize parentMode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Content styles
    lblCountry.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0f];
    lblCountry.textColor = [UIColor colorFromHex:@"#f26361"];
    
    // Artist detail
    self.title = artist.name;
    lblCountry.text = [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:artist.country];
    CGFloat fontSize = [CITextHelper getTextBodyFontSizeWithIndex:[CITextHelper getTextBodyFontSizeIndex]];
    lblBio.attributedText = [CITextHelper attributedStringFromMarkdown:artist.bio fontSize:fontSize];
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [lblBio addGestureRecognizer:pinchGesture];

    // Configure nav button
    CINavigationItem *navItem = (CINavigationItem *)self.navigationItem;
    [navItem setLeftBarButtonType:CINavigationItemLeftBarButtonTypeBack target:self action:@selector(navLeftButtonDidPress:)];
    
    // Configure map container
    artistMapContainer.backgroundColor = [UIColor colorFromHex:@"#cccccc"];
    
    // Configure map view
    CGFloat distance = 300.0f;
    if ([lblCountry.text isEqualToString:@"China"]) {
        distance = 2000.0f;
    } else if ([lblCountry.text isEqualToString:@"Russia"]) {
        distance = 1200.0f;
    } else if ([lblCountry.text isEqualToString:@"United States"]) {
        distance = 1700.0f;
    } else if ([lblCountry.text isEqualToString:@"Germany"]) {
        distance = 600.0f;
    } else if ([lblCountry.text isEqualToString:@"Brazil"]) {
        distance = 1000.0f;
    } else if ([lblCountry.text isEqualToString:@"Australia"]) {
        distance = 1500.0f;
    } else if ([lblCountry.text isEqualToString:@"Canada"]) {
        distance = 1300.0f;
    }
    CLGeocoder *geoCode = [[CLGeocoder alloc] init];
    [geoCode geocodeAddressString:lblCountry.text completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error && [placemarks count] > 0) {
            CLPlacemark *place = [placemarks objectAtIndex:0];
            CLLocation *location = place.location;
            CLLocationCoordinate2D coord = location.coordinate;
            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(coord, distance*METERS_PER_MILE, distance*METERS_PER_MILE);
            [artistMapView setRegion:viewRegion animated:NO];
            [UIView animateWithDuration:0.3f animations:^{
                artistMapView.alpha = 1.0f;
            }];
        }
    }];
    
    // Links
    links = self.artist.links;
    if ([links count] > 0) {
        CGFloat tableHeight = [links count] * LINKS_CELL_HEIGHT;
        NSLayoutConstraint *con1 = [NSLayoutConstraint constraintWithItem:linksTableView
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:0
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1
                                                                 constant:tableHeight];
        [linksTableView removeConstraints:linksTableView.constraints];
        [linksTableView addConstraint:con1];
        // Ugly height fix for container
        for (NSLayoutConstraint *con in linksContainer.constraints) {
            if (con.firstItem == linksContainer && con.secondItem == nil) {
                [linksContainer removeConstraint:con];
                NSLayoutConstraint *con2 = [NSLayoutConstraint constraintWithItem:linksContainer
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:0
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1
                                                                         constant:(tableHeight + 31.0f)];
                [linksContainer addConstraint:con2];
                break;
            }
        }
        
        // Tableview separator inset
        if ([linksTableView respondsToSelector:@selector(separatorInset)]) {
            linksTableView.separatorInset = UIEdgeInsetsZero;
        }
    } else {
        [linksContainer removeFromSuperview];
        
        // Adjust constraints
        NSLayoutConstraint *con1 = [NSLayoutConstraint constraintWithItem:lblBio
                                                                attribute:NSLayoutAttributeBottom
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:parentScrollView
                                                                attribute:NSLayoutAttributeBaseline
                                                               multiplier:1
                                                                 constant:-13];
        [parentScrollView addConstraint:con1];
    }
    
    // Set the tab bar background
    tabBarView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tab_bg"]];
    
    // Configure the sequence
    if (self.artist == nil) {
        // TODO: Handle somehow?
    } else {
        currentSequenceIndex = [self.artists indexOfObject:self.artist];
        if (currentSequenceIndex == NSNotFound) {
            // TODO: Handle somehow?
        } else {
            // Update the label
            NSString *strSequenceCurrent = [NSString stringWithFormat:@"%tu", (currentSequenceIndex + 1)];
            NSString *strSequenceTotal = [NSString stringWithFormat:@"%lu", (unsigned long)[self.artists count]];
            NSString *strSequenceFinal = [NSString stringWithFormat:@"%@ of %@", strSequenceCurrent, strSequenceTotal];
            
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            paragraphStyle.alignment = NSTextAlignmentCenter;
            paragraphStyle.lineSpacing = 3.0f;
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:strSequenceFinal];
            [string addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                   [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f], NSFontAttributeName,
                                   paragraphStyle, NSParagraphStyleAttributeName,
                                   [UIColor whiteColor], NSForegroundColorAttributeName,
                                   nil]
                            range:NSMakeRange(0, strSequenceFinal.length)];
            [string addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                   [UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0f], NSFontAttributeName,
                                   nil]
                            range:NSMakeRange(0, strSequenceCurrent.length)];
            [string addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                   [UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0f], NSFontAttributeName,
                                   nil]
                            range:NSMakeRange(strSequenceCurrent.length + 4, strSequenceTotal.length)];
            lblSequence.attributedText = string;
            
            // Prev/next buttons active?
            if (currentSequenceIndex == 0) {
                btnSequencePrev.enabled = NO;
            }
            if ([self.artists count] == (currentSequenceIndex + 1)) {
                btnSequenceNext.enabled = NO;
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)navLeftButtonDidPress:(id)sender {
    if ([self.parentMode isEqualToString:@"code"]) {
        [self performSegueWithIdentifier:@"exitArtistDetailToCode" sender:self];
    } else if ([self.parentMode isEqualToString:@"artwork"]) {
        [self performSegueWithIdentifier:@"exitArtistDetailToArtwork" sender:self];
    } else {
        [self performSegueWithIdentifier:@"exitArtistDetail" sender:self];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    // Country flag
    // Images from: http://openiconlibrary.sourceforge.net
    NSString *flagFilename = [NSString stringWithFormat:@"flag-%@", [artist.country lowercaseString]];
    NSString *flagFilepath = [[NSBundle mainBundle] pathForResource:flagFilename ofType:@"png"];
    NSData *flagData = [NSData dataWithContentsOfFile:flagFilepath];
    if (flagData) {
        UIImage *flagImage = [UIImage imageWithData:flagData scale:2.0f];
        flagView = [[UIImageView alloc] initWithImage:flagImage];
        flagView.backgroundColor = [UIColor colorFromHex:@"#e2e2e2"];
        CGFloat left = self.navigationController.view.frame.size.width - 30.0f - 15.0f;
        CGFloat top = self.navigationController.navigationBar.frame.size.height - 30.0f - 8.0f;
        flagView.frame = (CGRect){{left, top}, {30.0f, 30.0f}};
        flagView.layer.cornerRadius = 30.0f / 2.0f;
        flagView.alpha = 0.0f;
        flagView.clipsToBounds = YES;
        [self.navigationController.navigationBar addSubview:flagView];
        [UIView animateWithDuration:0.3f delay:0.2f options:0 animations:^{
            flagView.alpha = 1.0f;
        } completion:nil];
    }
    
    // Deselect links table row
    NSIndexPath *selectedIndexPath = [linksTableView indexPathForSelectedRow];
    if (selectedIndexPath != nil) {
        [linksTableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIView animateWithDuration:0.2f animations:^{
        flagView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [flagView removeFromSuperview];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    // Analytics
    [CIAnalyticsHelper sendEvent:@"ArtistDetail" withLabel:self.artist.code];
}

- (IBAction)segueToArtistDetail:(UIStoryboardSegue *)segue {
}

#pragma mark - Font resizing

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            pinchScale = gesture.scale;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if ((gesture.scale - pinchScale) >= kCIFontResizeThreshhold) {
                CITextBodyFontSizeIndex fontIndex = [CITextHelper getTextBodyFontSizeIndex];
                if (fontIndex != CITextBodyFontSizeIndexExtraLarge) {
                    fontIndex++;
                    CGFloat fontSize = [CITextHelper getTextBodyFontSizeWithIndex:fontIndex];
                    [CITextHelper setTextBodyFontSize:fontIndex];
                    [self updateTextBodyWithFontSize:fontSize];
                }
                pinchScale = gesture.scale;
            } else if ((pinchScale - gesture.scale) >= kCIFontResizeThreshhold) {
                CITextBodyFontSizeIndex fontIndex = [CITextHelper getTextBodyFontSizeIndex];
                if (fontIndex != CITextBodyFontSizeIndexSmall) {
                    fontIndex--;
                    CGFloat fontSize = [CITextHelper getTextBodyFontSizeWithIndex:fontIndex];
                    [CITextHelper setTextBodyFontSize:fontIndex];
                    [self updateTextBodyWithFontSize:fontSize];
                }
                pinchScale = gesture.scale;
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
            break;
        }
            
        default:
            break;
    }
}

- (void)updateTextBodyWithFontSize:(CGFloat)fontSize {
    // Update font with new size
    lblBio.attributedText = [CITextHelper attributedStringFromMarkdown:artist.bio fontSize:fontSize];
    
    // Calculate rendered size & update auto layout constraint
    CGSize size = [lblBio intrinsicContentSize];
    if (lblBioHeightConstraint != nil) {
        [lblBio removeConstraint:lblBioHeightConstraint];
    }
    lblBioHeightConstraint = [NSLayoutConstraint constraintWithItem:lblBio
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:0
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:size.height];
    [lblBio addConstraint:lblBioHeightConstraint];
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [links count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CILinkCell";
    CILinkCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CILinkCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Find link data
    CILink *link = [links objectAtIndex:indexPath.row];
    cell.textLabel.text = link.title;
    cell.detailTextLabel.text = link.url;
    
    // Style the cell
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
    cell.textLabel.textColor = [UIColor colorFromHex:@"#556270"];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:11.0f];
    cell.detailTextLabel.textColor = [UIColor colorFromHex:@"#556270"];
    cell.indentationWidth = 25.0f;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return LINKS_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showBrowser" sender:self];
}

#pragma mark - See artworks

- (IBAction)seeArtworksDidPress:(id)sender {
    if ([self.artist.artworks count] == 0) {
        return;
    } else if ([self.artist.artworks count] == 1) {
        [self performSegueWithIdentifier:@"showArtworkDetail" sender:self];
    } else {
        [self performSegueWithIdentifier:@"showArtworkList" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSArray *artworks = self.artist.artworks;
    if ([segue.identifier isEqualToString:@"showArtworkList"]) {
        CIArtworkListViewController *artworkListViewController = (CIArtworkListViewController *)segue.destinationViewController;
        artworkListViewController.artworks = artworks;
        artworkListViewController.parentMode = @"artistDetail";
    } else if ([segue.identifier isEqualToString:@"showArtworkDetail"]) {
        CIArtwork *artwork = [artworks objectAtIndex:0];
        CIArtworkDetailViewController *artworkDetailViewController = (CIArtworkDetailViewController *)segue.destinationViewController;
        artworkDetailViewController.hidesBottomBarWhenPushed = YES;
        artworkDetailViewController.artworks = @[artwork];
        artworkDetailViewController.artwork = artwork;
        artworkDetailViewController.parentMode = @"artistDetail";
    } else if ([segue.identifier isEqualToString:@"showPrevArtistDetail"]) {
        // Find the artist
        CIArtist *sequenceArtist = [self.artists objectAtIndex:(currentSequenceIndex - 1)];
        
        // Configure the controller
        CIArtistDetailViewController *artistDetailViewController = (CIArtistDetailViewController *)segue.destinationViewController;
        artistDetailViewController.artist = sequenceArtist;
        artistDetailViewController.artists = self.artists;
    } else if ([segue.identifier isEqualToString:@"showNextArtistDetail"]) {
        // Find the artist
        CIArtist *sequenceArtist = [self.artists objectAtIndex:(currentSequenceIndex + 1)];
        
        // Configure the controller
        CIArtistDetailViewController *artistDetailViewController = (CIArtistDetailViewController *)segue.destinationViewController;
        artistDetailViewController.artist = sequenceArtist;
        artistDetailViewController.artists = self.artists;
    } else if ([segue.identifier isEqualToString:@"showBrowser"]) {
        // Find the link
        NSIndexPath *indexPath = [linksTableView indexPathForSelectedRow];
        if (indexPath != nil) {
            CILink *link = [links objectAtIndex:indexPath.row];
            CIBrowserViewController *browserViewController = (CIBrowserViewController *)segue.destinationViewController;
            browserViewController.parentMode = @"artistDetail";
            browserViewController.viewTitle = link.title;
            browserViewController.url = link.url;
        }
    }
}

@end