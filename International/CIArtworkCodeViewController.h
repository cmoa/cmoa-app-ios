//
//  CIArtworkCodeViewController.h
//  International
//
//  Created by Dimitry Bentsionov on 8/2/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CIBorderedButton.h"

@interface CIArtworkCodeViewController : UIViewController <UIAlertViewDelegate> {
    IBOutlet UIView *codeContainer;
    IBOutlet UITextField *codeTextField;
    IBOutlet UILabel *lblNote;
    IBOutlet CIBorderedButton *btnSearch;
    CIArtwork *artwork;
}

@property (nonatomic, retain) NSString *parentMode;

@end