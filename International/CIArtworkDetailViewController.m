//
//  CIArtworkDetailViewController.m
//  International
//
//  Created by Dimitry Bentsionov on 7/10/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <Social/Social.h>
#import "CIArtworkDetailViewController.h"
#import "AFNetworking.h"
#import "CINavigationItem.h"
#import "CIArtworkSliderCell.h"
#import "CIVideoSliderCell.h"
#import "CIArtworkPhotoDetailViewController.h"
#import "CIArtworkAudioListViewController.h"
#import "CIAPIRequest.h"

#define CELL_WIDTH 137
#define PHOTO_CELL_IDENTIFIER @"CIArtworkSliderCell"
#define VIDEO_CELL_IDENTIFIER @"CIVideoSliderCell"

@interface CIArtworkDetailViewController () {
    CGFloat pinchScale;
}

@end

@implementation CIArtworkDetailViewController

@synthesize artwork;
@synthesize artworks;
@synthesize parentMode;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Content styles
    lblTitle.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
    lblDescription.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    [lblArtist addTopSeparator];
    
    // Show artwork details
    self.title = artwork.title;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineSpacing = 2.0f;
    NSMutableAttributedString *strTitle = [[NSMutableAttributedString alloc] initWithString:artwork.title];
    [strTitle addAttribute:NSFontAttributeName
                     value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0f]
                     range:NSMakeRange(0, [artwork.title length])];
    [strTitle addAttribute:NSForegroundColorAttributeName
                     value:[UIColor colorFromHex:kCIBlackTextColor]
                     range:NSMakeRange(0, [artwork.title length])];
    [strTitle addAttribute:NSParagraphStyleAttributeName
                     value:paragraphStyle
                     range:NSMakeRange(0, [artwork.title length])];
    lblTitle.attributedText = strTitle;
    CGFloat fontSize = [CITextHelper getTextBodyFontSizeWithIndex:[CITextHelper getTextBodyFontSizeIndex]];
    lblDescription.attributedText = [CITextHelper attributedStringFromMarkdown:artwork.body fontSize:fontSize];
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [lblDescription addGestureRecognizer:pinchGesture];
    
    // Artist(s)
    NSArray *artists = artwork.artists;
    if ([artists count] > 1) {
        NSString *artistNames = @"";
        CGFloat height = lblArtistHeightConstraint.constant;
        
        for (CIArtist *artist in artists) {
            if (artist == [artists lastObject]) {
                artistNames = [artistNames stringByAppendingString:artist.name];
            } else {
                height += 22;
                artistNames = [artistNames stringByAppendingFormat:@"%@\n", artist.name];
            }
        }
        
        [lblArtist setText:artistNames];
        lblArtistHeightConstraint.constant = height;
    } else {
        CIArtist *artist = [artists objectAtIndex:0];
        [lblArtist setText:artist.name];
    }
    
    // Configure audio (if any)
    NSArray *audio = artwork.audio;
    if ([audio count] > 0) {
        audioView.delegate = self;
        audioView.medium = [audio objectAtIndex:0];
    } else {
        // No audio... remove audio view
        [audioView removeFromSuperview];
        audioView = nil;
    }
    
    // Configure the collection view
    photosCollectionContainer.backgroundColor = [UIColor colorFromHex:@"#e0e0e0"];
    [photosCollectionView registerClass:[CIArtworkSliderCell class] forCellWithReuseIdentifier:PHOTO_CELL_IDENTIFIER];
    [photosCollectionView registerClass:[CIVideoSliderCell class] forCellWithReuseIdentifier:VIDEO_CELL_IDENTIFIER];

    // Photos
    photos = [artwork images];
    
    // Videos
    videos = [artwork videos];
    if (([photos count] + [videos count]) == 0) {
        // If no photos or videos, remove the slider container
        [photosCollectionContainer removeFromSuperview];
        photosCollectionContainer = nil;
        [photosCollectionContainer removeFromSuperview];
        photosCollectionContainer = nil;
    }
    
    // Configure nav button
    CINavigationItem *navItem = (CINavigationItem *)self.navigationItem;
    [navItem setLeftBarButtonType:CINavigationItemLeftBarButtonTypeBack target:self action:@selector(navLeftButtonDidPress:)];
    
    // Set the tab bar background
    tabBarView.backgroundColor = [UIColor colorFromHex:kCIBarColor];
    
    // Configure the sequence
    if (self.artworks == nil) {
        // TODO: Handle somehow?
    } else {
        currentSequenceIndex = [self.artworks indexOfObject:self.artwork];
        if (currentSequenceIndex == NSNotFound) {
            // TODO: Handle somehow?
        } else {
            // Update the label
            NSString *strSequenceCurrent = [NSString stringWithFormat:@"%tu", (currentSequenceIndex + 1)];
            NSString *strSequenceTotal = [NSString stringWithFormat:@"%lu", (unsigned long)[self.artworks count]];
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
            if ([self.artworks count] == (currentSequenceIndex + 1)) {
                btnSequenceNext.enabled = NO;
            }
        }
    }
    
    // Add page control
    if (([photos count] + [videos count]) > 1) {
        pageControl = [[SMPageControl alloc] init];
        pageControl.numberOfPages = ([photos count] + [videos count]);
        pageControl.pageIndicatorImage = [UIImage imageNamed:@"page_off.png"];
        pageControl.currentPageIndicatorImage = [UIImage imageNamed:@"page_on.png"];
        [pageControl sizeToFit];
        [photosCollectionContainer addSubview:pageControl];
        pageControl.userInteractionEnabled = NO;
    }
}

- (void)updateViewConstraints {
    [super updateViewConstraints];

    // Move the copy higher toward the photos
    if (audioView == nil && photosCollectionContainer != nil) {
        for (NSLayoutConstraint *con in detailContainer.constraints) {
            if (con.firstItem == lblTitle && con.secondItem == detailContainer && con.firstAttribute == NSLayoutAttributeTop) {
                con.constant = 201.0f + 13.0f;
                break;
            }
        }
    } else if (audioView == nil && photosCollectionContainer == nil) {
        for (NSLayoutConstraint *con in detailContainer.constraints) {
            if (con.firstItem == lblTitle && con.secondItem == detailContainer && con.firstAttribute == NSLayoutAttributeTop) {
                con.constant = 0.0f + 13.0f;
            } else if (con.firstItem == audioView || con.firstItem == photosCollectionContainer || con.secondItem == audioView || con.secondItem == photosCollectionContainer) {
                [detailContainer removeConstraint:con];
            }
        }
    } else if (audioView != nil && photosCollectionContainer == nil) {
        for (NSLayoutConstraint *con in detailContainer.constraints) {
            if (con.firstItem == audioView && con.secondItem == detailContainer && con.firstAttribute == NSLayoutAttributeTop) {
                con.constant = 0.0f;
            } else if (con.firstItem == lblTitle && con.secondItem == detailContainer && con.firstAttribute == NSLayoutAttributeTop) {
                con.constant = 50.0f + 13.0f;
            }
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [audioView cleanUp];
}

- (void)viewDidAppear:(BOOL)animated {
    // Analytics
    [CIAnalyticsHelper sendEvent:@"ArtworkDetail" withLabel:self.artwork.code];
}

- (void)viewWillLayoutSubviews {
    // Buggy fix for the ambiguous scroll view size
    scrollViewWidthConstraint.constant = self.view.frame.size.width;
    detailContainerWidthConstraint.constant = self.view.frame.size.width;
}

- (void)viewDidLayoutSubviews {
    // Center the page control
    CGFloat centerX = self.view.frame.size.width / 2.0f;
    pageControl.center = (CGPoint){centerX, 190.0f};
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)navLeftButtonDidPress:(id)sender {
    // Unwind appropriately
    if ([self.parentMode isEqualToString:@"photos"]) {
        [self performSegueWithIdentifier:@"exitArtworkDetailToPhotos" sender:self];
    } else if ([self.parentMode isEqualToString:@"tours"]) {
        [self performSegueWithIdentifier:@"exitArtworkDetailToTours" sender:self];
    } else if ([self.parentMode isEqualToString:@"artworks"]) {
        [self performSegueWithIdentifier:@"exitArtworkDetailToList" sender:self];
    } else if ([self.parentMode isEqualToString:@"code"]) {
        [self performSegueWithIdentifier:@"exitArtworkDetailToCode" sender:self];
    } else if ([self.parentMode isEqualToString:@"artistDetail"]) {
        [self performSegueWithIdentifier:@"exitArtworkDetailToArtistDetail" sender:self];
    }
}

- (IBAction)segueToArtworkDetail:(UIStoryboardSegue *)segue {
}

- (void)viewWillAppear:(BOOL)animated {
    // Set cell to deselected
    if (photosCollectionView != nil) {
        NSArray *selectedItems = [photosCollectionView indexPathsForSelectedItems];
        if ([selectedItems count] > 0) {
            NSIndexPath *selectedIndexPath = [selectedItems objectAtIndex:0];
            
            // Distinguish between photos & videos
            if (selectedIndexPath.row < [photos count]) {
                CIArtworkSliderCell *cell = (CIArtworkSliderCell *)[photosCollectionView cellForItemAtIndexPath:selectedIndexPath];
                [cell performSelectionAnimation:NO];
            } else {
                CIVideoSliderCell *cell = (CIVideoSliderCell *)[photosCollectionView cellForItemAtIndexPath:selectedIndexPath];
                [cell performSelectionAnimation:NO];
            }
        }
    }
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
    lblDescription.attributedText = [CITextHelper attributedStringFromMarkdown:artwork.body fontSize:fontSize];
    
    // Calculate rendered size & update auto layout constraint
    CGSize size = [lblDescription intrinsicContentSize];
    if (lblDescriptionHeightConstraint != nil) {
        [lblDescription removeConstraint:lblDescriptionHeightConstraint];
    }
    lblDescriptionHeightConstraint = [NSLayoutConstraint constraintWithItem:lblDescription
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:0
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:size.height];
    [lblDescription addConstraint:lblDescriptionHeightConstraint];
}

#pragma mark - Collection view delegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.frame.size.width, 200);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return ([photos count] + [videos count]);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Photo/Video distinction
    if (indexPath.row < [photos count]) {
        // Prepare the cell
        CIArtworkSliderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PHOTO_CELL_IDENTIFIER
                                                                              forIndexPath:indexPath];
        
        // Find photo
        CIMedium *photo = [photos objectAtIndex:indexPath.row];
        cell.medium = photo;

        return cell;
    } else {
        // Prepare the cell
        CIVideoSliderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:VIDEO_CELL_IDENTIFIER
                                                                            forIndexPath:indexPath];
        
        // Find video
        CIMedium *video = [videos objectAtIndex:(indexPath.row - [photos count])];
        cell.medium = video;

        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // Distinguish between photos & videos
    if (indexPath.row < [photos count]) { // Photos
        // Show photo detail view controller
        [self performSegueWithIdentifier:@"showPhotoDetail" sender:nil];
        
        // Set cell to selected
        CIArtworkSliderCell *cell = (CIArtworkSliderCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [cell performSelectionAnimation:YES];
    } else { // Videos
        CIMedium *video = [videos objectAtIndex:(indexPath.row - [photos count])];
        NSURL *videoURL = [NSURL URLWithString:video.urlFull];
        moviePlayerController = [[CIVideoPlayerViewController alloc] init];
        moviePlayerController.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
        moviePlayerController.moviePlayer.contentURL = videoURL;
        [self presentMoviePlayerViewControllerAnimated:moviePlayerController];

        // Set cell to selected
        CIVideoSliderCell *cell = (CIVideoSliderCell *)[collectionView cellForItemAtIndexPath:indexPath];
        [cell performSelectionAnimation:YES];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // Set appropriate page for page control
    if (pageControl != nil) {
        NSInteger page = (scrollView.contentOffset.x / scrollView.frame.size.width);
        pageControl.currentPage = page;
    }
}

#pragma mark - Transition

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPhotoDetail"]) {
        // Find the photo
        NSArray *selectedItems = [photosCollectionView indexPathsForSelectedItems];
        NSIndexPath *selectedIndexPath = [selectedItems objectAtIndex:0];
        CIMedium *medium = [photos objectAtIndex:selectedIndexPath.row];
        if (medium != nil) {
            CIArtworkPhotoDetailViewController *photoDetailViewController = (CIArtworkPhotoDetailViewController *)segue.destinationViewController;
            photoDetailViewController.hidesBottomBarWhenPushed = YES;
            photoDetailViewController.medium = medium;
        }
    } else if ([segue.identifier isEqualToString:@"showPrevArtworkDetail"]) {
        // Find the artwork
        CIArtwork *sequenceArtwork = [artworks objectAtIndex:(currentSequenceIndex - 1)];

        // Configure the controller
        CIArtworkDetailViewController *artworkDetailViewController = (CIArtworkDetailViewController *)segue.destinationViewController;
        artworkDetailViewController.hidesBottomBarWhenPushed = YES;
        artworkDetailViewController.artworks = artworks;
        artworkDetailViewController.artwork = sequenceArtwork;
        artworkDetailViewController.parentMode = self.parentMode;
    } else if ([segue.identifier isEqualToString:@"showNextArtworkDetail"]) {
        // Find the artwork
        CIArtwork *sequenceArtwork = [artworks objectAtIndex:(currentSequenceIndex + 1)];

        // Configure the controller
        CIArtworkDetailViewController *artworkDetailViewController = (CIArtworkDetailViewController *)segue.destinationViewController;
        artworkDetailViewController.hidesBottomBarWhenPushed = YES;
        artworkDetailViewController.artworks = artworks;
        artworkDetailViewController.artwork = sequenceArtwork;
        artworkDetailViewController.parentMode = self.parentMode;
    } else if ([segue.identifier isEqualToString:@"showArtworkAudioList"]) {
        // Configure the controller
        CIArtworkAudioListViewController *artworkAudioListViewController = (CIArtworkAudioListViewController *)segue.destinationViewController;
        artworkAudioListViewController.artwork = self.artwork;
    }
}

#pragma mark - Audio view delegate

- (void)audioViewMoreDidPress:(CIAudioView *)audioView medium:(CIMedium *)medium {
    [self performSegueWithIdentifier:@"showArtworkAudioList" sender:self];
}

#pragma mark - Share

- (IBAction)shareDidPress:(id)sender {
    UIActionSheet *shareSheet = [[UIActionSheet alloc] initWithTitle:@"Share artwork"
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:@"Facebook", @"Twitter", @"Email", @"Text Message", nil];
    if (IS_IPHONE) {
        [shareSheet showInView:self.view];
    } else {
        [shareSheet showFromRect:tabBarView.frame inView:self.view animated:YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *shareText = [NSString stringWithFormat:@"%@ at Carnegie Museum of Art: %@ #cmoa", [CITextHelper artistsJoinedByComa:artwork.artists], artwork.shareUrl];
    
    // Which action?
    switch (buttonIndex) {
        // Facebook
        case 0: {
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
                SLComposeViewController *shareController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                [shareController setInitialText:shareText];
                [self presentViewController:shareController animated:YES completion:nil];
            } else {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Uhoh"
                                      message:@"Please add a Facebook account to your iPhone to enable this option."
                                      delegate:nil
                                      cancelButtonTitle:@"Ok"
                                      otherButtonTitles:nil];
                [alert show];
            }
        }
            break;

        // Twitter
        case 1: {
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
                SLComposeViewController *shareController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                [shareController setInitialText:shareText];
                [self presentViewController:shareController animated:YES completion:nil];
            } else {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Uhoh"
                                      message:@"Please add a Twitter account to your iPhone to enable this option."
                                      delegate:nil
                                      cancelButtonTitle:@"Ok"
                                      otherButtonTitles:nil];
                [alert show];
            }
        }
            break;

        // Email
        case 2: {
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
                mailViewController.mailComposeDelegate = self;
                [mailViewController setSubject:@"Carnegie Museum of Art"];
                [mailViewController setMessageBody:shareText isHTML:NO];
                [self presentViewController:mailViewController animated:YES completion:nil];
            } else {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Uh oh!"
                                      message:@"Please add an email account to your iPhone to enable this sharing option."
                                      delegate:nil
                                      cancelButtonTitle:@"Ok"
                                      otherButtonTitles:nil];
                [alert show];
            }
        }
            break;
            
        // Text Message
        case 3: {
            if ([MFMessageComposeViewController canSendText]) {
                messageComposeViewController = [[MFMessageComposeViewController alloc] init];
                messageComposeViewController.body = shareText;
                messageComposeViewController.messageComposeDelegate = self;
                [self presentViewController:messageComposeViewController animated:YES completion:nil];
            } else {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"Uhoh"
                                      message:@"Could not create a new text message on this device."
                                      delegate:nil
                                      cancelButtonTitle:@"Ok"
                                      otherButtonTitles:nil];
                [alert show];
            }
        }
            break;

        default:
            break;
    }
}

#pragma mark - Message & Mail delegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Location

- (IBAction)locationDidPress:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location"
                                                        message:[NSString stringWithFormat:@"%@ is located in:\n%@", self.artwork.title, self.artwork.location.name]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

@end