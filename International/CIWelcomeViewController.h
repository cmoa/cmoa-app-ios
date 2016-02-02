//
//  CIWelcomeViewController.h
//  International
//
//  Created by Dimitry Bentsionov on 7/9/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CIWelcomeButton.h"

@interface CIWelcomeViewController : UIViewController {
    IBOutlet UIImageView *headerImage;
    IBOutlet UIView *navContainer;
    IBOutlet UIButton *btnSearch;
    IBOutlet CIWelcomeButton *btnMyVisit;
    IBOutlet CIWelcomeButton *btnExhibitions;
    IBOutlet CIWelcomeButton *btnLocationList;
    IBOutlet CIWelcomeButton *btnMuseumNews;
    IBOutlet CIWelcomeButton *btnCMOATV;
    IBOutlet CIWelcomeButton *btnConnect;
    IBOutlet NSLayoutConstraint *conSearchButton;
    IBOutlet NSLayoutConstraint *conNavContainer;
    BOOL is4InchiPhone;
    
    // Background download
    CGFloat totalDownloadSize;
    CGFloat totalDownloadedSize;
    NSMutableArray *exhibitionsToDownload;
}

@end