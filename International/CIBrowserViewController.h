//
//  CIBrowserViewController.h
//  CMOA
//
//  Created by Dimitry Bentsionov on 9/2/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenInChromeController.h"

@interface CIBrowserViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate> {
    IBOutlet UIWebView *mainWebView;
    IBOutlet UIView *errorView;

    // Google Chrome helper
    OpenInChromeController *openInChromeController;
}

@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *viewTitle;
@property (nonatomic, retain) NSString *parentMode;

@end