//
//  CIArtworkCodeViewController.m
//  International
//
//  Created by Dimitry Bentsionov on 8/2/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CIArtworkCodeViewController.h"
#import "CINavigationItem.h"
#import "CIArtworkDetailViewController.h"

#define kGodModeAlertViewTag 10

@interface CIArtworkCodeViewController ()

@property (nonatomic) UITapGestureRecognizer *dismissKeyboardTapRecognizer;

@end

@implementation CIArtworkCodeViewController

@synthesize parentMode;
@synthesize dismissKeyboardTapRecognizer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:
     UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:
     UIKeyboardWillHideNotification object:nil];
    
    dismissKeyboardTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                            action:@selector(dismissKeyboard)];
    
    // Configure nav button
    if ([CIAppState sharedAppState].currentLocation == nil) {
        CINavigationItem *navItem = (CINavigationItem *)self.navigationItem;
        [navItem setLeftBarButtonType:CINavigationItemLeftBarButtonTypeBack target:self action:@selector(navLeftButtonDidPress:)];
    }
    
    // Note label setup
    NSString *strNote = @"To access information\nabout a specific object,\nplease enter the object code here:";
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineSpacing = 5.0f;
    
    NSAttributedString *strNoteAttr = [[NSAttributedString alloc] initWithString:strNote attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0f], NSFontAttributeName, [UIColor colorFromHex:@"#556270"], NSForegroundColorAttributeName, paragraphStyle, NSParagraphStyleAttributeName, nil]];
    lblNote.attributedText = strNoteAttr;
    
    // Configure code entry
    codeTextField.textColor = [UIColor colorFromHex:@"#556270"];
    codeContainer.layer.masksToBounds = YES;
    codeContainer.layer.borderColor = [UIColor colorFromHex:@"#dde0e2"].CGColor;
    codeContainer.layer.borderWidth = 5.0f;

    // Button style
    btnSearch.borderColor = [UIColor colorFromHex:kCILinkColor];
    btnSearch.borderHighligthedColor = [UIColor colorFromHex:kCIBarUnactiveColor];
    [btnSearch setTitleColor:[UIColor colorFromHex:kCILinkColor] forState:UIControlStateNormal];
    [btnSearch setTitleColor:[UIColor colorFromHex:kCIBarUnactiveColor] forState:UIControlStateHighlighted];
    
    // Add border to number keyboard (otherwise looks weird on iOS 7)
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        UIView *accessoryView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, {self.view.frame.size.width, 0.5f}}];
        accessoryView.backgroundColor = [UIColor colorFromHex:@"#c1c3c7"];
        codeTextField.inputAccessoryView = accessoryView;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    // Show the navigation bar
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    // Focus on the code field
    [codeTextField becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated {
    // Analytics
    [CIAnalyticsHelper sendEvent:@"CodeLookup"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)dismissKeyboard {
    [codeTextField resignFirstResponder];
}

- (void)navLeftButtonDidPress:(id)sender {
    if ([self.parentMode isEqualToString:@"home"]) {
        [self performSegueWithIdentifier:@"exitArtworkCodeToHome" sender:self];
    } else {
        [self performSegueWithIdentifier:@"exitArtworkCodeToExhibitionDetail" sender:self];
    }
}

- (IBAction)searchDidPress:(id)sender {
    NSString *searchStr = codeTextField.text;
    
    // God mode?
    if ([searchStr isEqualToString:@"440015213"]) {
        // Update the app state
        CIAppState *appState = [CIAppState sharedAppState];
        appState.isGodMode = YES;
        
        // Alert the user
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"God Mode"
                                                        message:@"Activated"
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        alert.tag = kGodModeAlertViewTag;
        [alert show];
        return;
    }
    
    // Searching for Artwork
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (code == %@)", searchStr];
    artwork = [CIArtwork MR_findFirstWithPredicate:predicate];
    if (artwork) {
        [self performSegueWithIdentifier:@"showArtworkDetail" sender:self];
        return;
    }
    
    // If we're here, neither was found
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Code"
                                                    message:@"Unfortunately, we could not find the object."
                                                   delegate:nil
                                          cancelButtonTitle:@"Try Again"
                                          otherButtonTitles:nil];
    [alert show];
}

- (IBAction)segueToArtworkCode:(UIStoryboardSegue *)segue {
}

#pragma mark - Transition

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showArtworkDetail"]) {
        CIArtworkDetailViewController *artworkDetailViewController = (CIArtworkDetailViewController *)segue.destinationViewController;
        artworkDetailViewController.hidesBottomBarWhenPushed = YES;
        artworkDetailViewController.artworks = @[artwork];
        artworkDetailViewController.artwork = artwork;
        artworkDetailViewController.parentMode = @"code";
    }
}

#pragma mark - Alert delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kGodModeAlertViewTag) {
        codeTextField.text = @"";
        if (IS_IPAD) {
            [codeTextField resignFirstResponder];
        } else {
            [self performSegueWithIdentifier:@"exitArtworkCodeToHome" sender:nil];
        }
    }
}

#pragma mark - Keyboard notifications

-(void) keyboardWillShow:(NSNotification *)note {
    [self.view addGestureRecognizer:dismissKeyboardTapRecognizer];
}

-(void) keyboardWillHide:(NSNotification *)note
{
    [self.view removeGestureRecognizer:dismissKeyboardTapRecognizer];
}

@end