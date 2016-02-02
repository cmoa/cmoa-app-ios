//
//  CIArtworkDetailViewController.h
//  International
//
//  Created by Dimitry Bentsionov on 7/10/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CIAudioView.h"
#import "CIArtworkTabButton.h"
#import "CIArtworkTabLblView.h"
#import "TTTAttributedLabel.h"
#import "CIVideoPlayerViewController.h"
#import "CIArtistLabel.h"
#import "SMPageControl.h"

@interface CIArtworkDetailViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, CIAudioViewDelegate, UIActionSheetDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UIScrollViewDelegate> {
    IBOutlet TTTAttributedLabel *lblDescription;
    IBOutlet CIArtistLabel *lblArtist;
    IBOutlet TTTAttributedLabel *lblTitle;
    IBOutlet UIView *photosCollectionContainer;
    IBOutlet UICollectionView *photosCollectionView;
    IBOutlet UIView *detailContainer;
    IBOutlet UIScrollView *parentScrollView;
    IBOutlet CIAudioView *audioView;
    SMPageControl *pageControl;
    NSArray *photos;
    NSArray *videos;
    NSArray *artworks;
    
    // Tab bar
    NSUInteger currentSequenceIndex;
    IBOutlet UIView *tabBarView;
    IBOutlet CIArtworkTabButton *btnSequenceNext;
    IBOutlet CIArtworkTabButton *btnSequencePrev;
    IBOutlet UILabel *lblSequence;
    IBOutlet UIButton *btnShareArtwork;
    
    // Text msg popup
    MFMessageComposeViewController *messageComposeViewController;
    
    // Video player
    CIVideoPlayerViewController *moviePlayerController;
    
    // Layout constraints
    NSLayoutConstraint *lblDescriptionHeightConstraint;
}

@property (nonatomic, retain) CIArtwork *artwork;
@property (nonatomic, retain) NSArray *artworks;
@property (nonatomic, retain) NSString *parentMode;

@end