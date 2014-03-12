//
//  CIExhibitionDetailViewController.h
//  International
//
//  Created by Dimitry Bentsionov on 7/22/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface CIExhibitionDetailViewController : UIViewController {
    CIExhibition *exhibition;
    IBOutlet UIView *navContainer;
    IBOutlet UIView *sponsorContainer;
    IBOutlet TTTAttributedLabel *lblSponsor;
    UIView *sponsorSepView;
    BOOL haveSponsorText;
}

@end