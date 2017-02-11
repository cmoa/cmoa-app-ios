//
//  CIExhibitionDetailViewController.m
//  International
//
//  Created by Dimitry Bentsionov on 7/22/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CIExhibitionDetailViewController.h"
#import "CINavigationController.h"
#import "CINavigationItem.h"
#import "UIImage+Resize.h"

@interface CIExhibitionDetailViewController ()

@end

@implementation CIExhibitionDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Load the exhibition
    exhibition = [CIAppState sharedAppState].currentExhibition;
    
    // Set the title
    self.title = exhibition.title;

    // Configure nav button
    CINavigationItem *navItem = (CINavigationItem *)self.navigationItem;
    [navItem setLeftBarButtonType:CINavigationItemLeftBarButtonTypeBack target:self action:@selector(navLeftButtonDidPress:)];
    
    // Backgrounds
    UIImage *bg = [UIImage imageWithContentsOfFile:[exhibition getBackgroundFilePath]];
    UIImage *bgBlurred = [UIImage imageWithContentsOfFile:[exhibition getBlurredBackgroundFilePath]];
    
    themeImageView.image = bg;
    themeImageViewBlurred.image = bgBlurred;
    
    CGFloat shownArea = themeImageViewBlurred.frame.size.height / themeImageView.frame.size.height;
    themeImageViewBlurred.layer.contentsRect = CGRectMake(0, 0, 1, shownArea);
    
    // Set sponsor text
    haveSponsorText = (exhibition.sponsor != nil && ![exhibition.sponsor isEqual:@""]);
    if (haveSponsorText == YES) {
        NSString *strSponsor = exhibition.sponsor;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineSpacing = 2.0f;
        NSMutableAttributedString *strTitle = [[NSMutableAttributedString alloc] initWithString:strSponsor];
        [strTitle addAttribute:NSFontAttributeName
                         value:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]
                         range:NSMakeRange(0, [strSponsor length])];
        [strTitle addAttribute:NSForegroundColorAttributeName
                         value:[UIColor colorFromHex:@"#2e2e2e"]
                         range:NSMakeRange(0, [strSponsor length])];
        [strTitle addAttribute:NSParagraphStyleAttributeName
                         value:paragraphStyle
                         range:NSMakeRange(0, [strSponsor length])];
        lblSponsor.attributedText = strTitle;
        [sponsorContainer setHidden:NO];
    } else {
        [sponsorContainer setHidden:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    // Show the navigation bar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    // Analytics
    [CIAnalyticsHelper sendScreen:@"Exhibition Detail"];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier  isEqual: @"Exhibition Objects"] ||
        [segue.identifier  isEqual: @"Exhibition Tours"]) {
        [[NSNotificationCenter defaultCenter]
            postNotificationName:kCISelectedExhibitionNotification
            object:NULL];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)navLeftButtonDidPress:(id)sender {
    [self performSegueWithIdentifier:@"exitExhibitionDetail" sender:self];
}

- (IBAction)segueToExhibitionDetail:(UIStoryboardSegue *)segue {
}

@end