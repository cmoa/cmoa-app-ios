//
//  CIArtistDetailViewController.h
//  International
//
//  Created by Dimitry Bentsionov on 7/9/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CIArtworkTabButton.h"
#import "NSAttributedStringMarkdownParser.h"
#import "TTTAttributedLabel.h"

@interface CIArtistDetailViewController : UIViewController {
    IBOutlet UIScrollView *parentScrollView;
    IBOutlet UIView *artistMapContainer;
    IBOutlet MKMapView *artistMapView;
    IBOutlet UILabel *lblCountry;
    IBOutlet TTTAttributedLabel *lblBio;
    IBOutlet UIView *linksContainer;
    IBOutlet UILabel *lblLinks;
    IBOutlet UITableView *linksTableView;
    UIImageView *flagView;
    NSArray *links;
    
    // Tab bar
    NSUInteger currentSequenceIndex;
    IBOutlet UIView *tabBarView;
    IBOutlet CIArtworkTabButton *btnSequenceNext;
    IBOutlet CIArtworkTabButton *btnSequencePrev;
    IBOutlet UILabel *lblSequence;
    
    // Layout constraints
    NSLayoutConstraint *lblBioHeightConstraint;
}

@property (nonatomic, retain) CIArtist *artist;
@property (nonatomic, retain) NSArray *artists;
@property (nonatomic, retain) NSString *parentMode;

@end