//
//  CIConnectViewController.h
//  CMOA
//
//  Created by Dimitry Bentsionov on 8/19/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CIBorderedButton.h"

@interface CIConnectViewController : UIViewController <UITextFieldDelegate> {
    IBOutlet UIView *emailContainer;
    IBOutlet UITextField *emailTextField;
    IBOutlet UILabel *lblNote;
    IBOutlet CIBorderedButton *btnSubscribe;
    NSString *visitURL;
    NSString *visitTitle;
}

@end