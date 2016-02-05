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
    IBOutlet UIView *navContainer;
    IBOutlet UIButton *btnSearch;
    IBOutlet CIWelcomeButton *btnMyVisit;
    IBOutlet CIWelcomeButton *btnExhibitions;
    IBOutlet CIWelcomeButton *btnMuseumNews;
    IBOutlet CIWelcomeButton *btnCMOATV;
    IBOutlet CIWelcomeButton *btnConnect;
    
    __weak IBOutlet UIImageView *themeImageView;
    __weak IBOutlet UIImageView *themeImageViewBlurred;
    
    // Background download
    CGFloat totalDownloadSize;
    CGFloat totalDownloadedSize;
    NSMutableArray *exhibitionsToDownload;
}

@end