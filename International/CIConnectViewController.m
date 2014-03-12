//
//  CIConnectViewController.m
//  CMOA
//
//  Created by Dimitry Bentsionov on 8/19/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CIConnectViewController.h"
#import "CINavigationItem.h"
#import "CIAPIRequest.h"
#import "CIBrowserViewController.h"

@interface CIConnectViewController ()

@end

@implementation CIConnectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Configure nav button
    CINavigationItem *navItem = (CINavigationItem *)self.navigationItem;
    if (IS_IPHONE) {
        [navItem setLeftBarButtonType:CINavigationItemLeftBarButtonTypeMenu target:self action:@selector(navLeftButtonDidPress:)];
    }
    [navItem setRightBarButtonType:CINavigationItemRightBarButtonTypeSocial target:self action:@selector(navRightButtonDidPress:)];
    
    // Note label setup
    NSString *strNote = @"Stay connected with Carnegie Museum of Art.\nEnter your email address below to receive updates about exhibitions, events and museum news.";
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineSpacing = 5.0f;
    
    NSAttributedString *strNoteAttr = [[NSAttributedString alloc] initWithString:strNote attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0f], NSFontAttributeName, [UIColor colorFromHex:@"#556270"], NSForegroundColorAttributeName, paragraphStyle, NSParagraphStyleAttributeName, nil]];
    lblNote.attributedText = strNoteAttr;
    
    // Configure code entry
    emailTextField.textColor = [UIColor colorFromHex:@"#556270"];
    emailContainer.layer.masksToBounds = YES;
    emailContainer.layer.borderColor = [UIColor colorFromHex:@"#dde0e2"].CGColor;
    emailContainer.layer.borderWidth = 5.0f;
    
    // Button style
    [btnSubscribe setTitleColor:[UIColor colorFromHex:@"#24aadc"] forState:UIControlStateNormal];
    [btnSubscribe setTitleColor:[UIColor colorFromHex:@"#24aadc" alpha:0.6f] forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    // Show the navigation bar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // Focus on the code field
    [emailTextField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    // Analytics
    [CIAnalyticsHelper sendEvent:@"ConnectEmail"];
}

- (void)viewWillDisappear:(BOOL)animated {
    // Blur the code field
    [emailTextField resignFirstResponder];
}

- (void)navLeftButtonDidPress:(id)sender {
    [self performSegueWithIdentifier:@"exitConnect" sender:self];
}

- (void)navRightButtonDidPress:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button.tag == 0) {
        // Facebook
        visitTitle = @"CMOA on Facebook";
        visitURL = @"https://www.facebook.com/CarnegieMuseumofArt";
    } else {
        // Twitter
        visitTitle = @"CMOA on Twitter";
        visitURL = @"https://twitter.com/cmoa";
    }
    
    // Show the browser
    [self performSegueWithIdentifier:@"showBrowser" sender:self];
}

- (IBAction)segueToConnect:(UIStoryboardSegue *)segue {
}

#pragma mark - Subscribe handler

- (IBAction)subscribeDidPress:(id)sender {
    // Validate email
    if ([self isValidEmail:emailTextField.text] == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid email"
                                                        message:@"Please enter a valid email address to sign up."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [emailTextField becomeFirstResponder];
        return;
    }
    
    // Email valid, subscribe
    emailTextField.enabled = NO;
    btnSubscribe.enabled = NO;
    
    // API subscribe call
    CIAPIRequest *apiRequest = [[CIAPIRequest alloc] init];
    [apiRequest subscribeEmail:emailTextField.text
                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                           [emailContainer removeFromSuperview];
                           [btnSubscribe removeFromSuperview];
                           
                           // Note label
                           NSString *strNote = @"Thank you!\nPlease check your email inbox for a confirmation email.";
                           NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                           paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                           paragraphStyle.alignment = NSTextAlignmentCenter;
                           paragraphStyle.lineSpacing = 5.0f;
                           
                           NSAttributedString *strNoteAttr = [[NSAttributedString alloc] initWithString:strNote attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0f], NSFontAttributeName, [UIColor colorFromHex:@"#556270"], NSForegroundColorAttributeName, paragraphStyle, NSParagraphStyleAttributeName, nil]];
                           lblNote.attributedText = strNoteAttr;
                       }
                       failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                           NSLog(@"Error: %@ %@", error, JSON);
                           emailTextField.enabled = YES;
                           btnSubscribe.enabled = YES;
                           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Subscription error"
                                                                           message:@"We could not sign you up at this time. Please try again later."
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"OK"
                                                                 otherButtonTitles:nil];
                           [alert show];
                           [emailTextField becomeFirstResponder];
                       }];
}

- (BOOL)isValidEmail:(NSString *)checkString {
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self subscribeDidPress:nil];
    return YES;
}

#pragma mark - Transition

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showBrowser"]) {
        CIBrowserViewController *browserViewController = (CIBrowserViewController *)segue.destinationViewController;
        browserViewController.parentMode = @"connect";
        browserViewController.viewTitle = visitTitle;
        browserViewController.url = visitURL;
    }
}

@end