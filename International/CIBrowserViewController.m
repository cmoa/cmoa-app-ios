//
//  CIBrowserViewController.m
//  CMOA
//
//  Created by Dimitry Bentsionov on 9/2/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIBrowserViewController.h"
#import "CINavigationItem.h"

@interface CIBrowserViewController ()

@end

@implementation CIBrowserViewController

@synthesize url;
@synthesize parentMode;
@synthesize viewTitle;

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
    [navItem setLeftBarButtonType:CINavigationItemLeftBarButtonTypeBack target:self action:@selector(navLeftButtonDidPress:)];
    [navItem setRightBarButtonType:CINavigationItemRightBarButtonTypeOpenInSafari target:self action:@selector(navRightButtonDidPress:)];
    
    // Set title
    self.title = self.viewTitle;
    
    // Load news
    NSURL *urlObj = [NSURL URLWithString:self.url];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlObj];
    [mainWebView loadRequest:request];
    
    // Open in Chrome controller
    openInChromeController = [[OpenInChromeController alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)navLeftButtonDidPress:(id)sender {
    if ([self.parentMode isEqualToString:@"artistDetail"]) {
        [self performSegueWithIdentifier:@"exitToArtistDetail" sender:self];
    } else if ([self.parentMode isEqualToString:@"visit"]) {
        [self performSegueWithIdentifier:@"exitToVisit" sender:self];
    } else if ([self.parentMode isEqualToString:@"museumNews"]) {
        [self performSegueWithIdentifier:@"exitToMuseumNews" sender:self];
    } else if ([self.parentMode isEqualToString:@"museumVideos"]) {
        [self performSegueWithIdentifier:@"exitToMuseumVideos" sender:self];
    } else if ([self.parentMode isEqualToString:@"connect"]) {
        [self performSegueWithIdentifier:@"exitToConnect" sender:self];
    }
}

- (void)navRightButtonDidPress:(id)sender {
    // Open action sheet
    UIActionSheet *popupQuery;
    if ([openInChromeController isChromeInstalled]) {
        popupQuery = [[UIActionSheet alloc] initWithTitle:self.viewTitle
                                                 delegate:self
                                        cancelButtonTitle:@"Cancel"
                                   destructiveButtonTitle:nil
                                        otherButtonTitles:@"Open in Safari", @"Open in Chrome", nil];
    } else {
        popupQuery = [[UIActionSheet alloc] initWithTitle:self.viewTitle
                                                 delegate:self
                                        cancelButtonTitle:@"Cancel"
                                   destructiveButtonTitle:nil
                                        otherButtonTitles:@"Open in Safari", nil];
    }
    if (IS_IPHONE) {
        [popupQuery showInView:self.view];
    } else {
        [popupQuery showFromRect:self.navigationItem.rightBarButtonItem.customView.frame inView:self.view animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    // Show the navigation bar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    // Analytics
    [CIAnalyticsHelper sendScreen:@"Internal Browser"];
}

#pragma mark - Webview delegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    // Show error view
    [webView removeFromSuperview];
    errorView.hidden = NO;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    
    return YES;
}

- (IBAction)visitDidPress:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.url]];
}

#pragma mark - Action Sheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // What action?
    switch (buttonIndex) {
            // Open in Safari
        case 0:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.url]];
            
            // Unload view
            [self performSegueWithIdentifier:@"exitToArtistDetail" sender:self];
            break;
            
            // Open in Chrome (or Cancel)
        case 1: {
            if ([openInChromeController isChromeInstalled]) {
                [openInChromeController openInChrome:[NSURL URLWithString:self.url]];
                
                // Unload view
                [self performSegueWithIdentifier:@"exitToArtistDetail" sender:self];
            }
        }
            break;
            
        default:
            break;
    }
}

@end