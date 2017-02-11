//
//  CIMuseumNewsViewController.m
//  International
//
//  Created by Dimitry Bentsionov on 8/6/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIMuseumNewsViewController.h"
#import "CINavigationItem.h"
#import "CIBrowserViewController.h"

#define FEED_URL @"https://s3.amazonaws.com/cmoa-cms-dev/feeds/news.html"

@interface CIMuseumNewsViewController ()

@end

@implementation CIMuseumNewsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Configure nav button
    if (IS_IPHONE) {
        CINavigationItem *navItem = (CINavigationItem *)self.navigationItem;
        [navItem setLeftBarButtonType:CINavigationItemLeftBarButtonTypeBack target:self action:@selector(navLeftButtonDidPress:)];
    }
    
    // Load news
    NSURL *url = [NSURL URLWithString:FEED_URL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [newsWebView loadRequest:request];
}

- (void)viewDidAppear:(BOOL)animated {
    // Analytics
    [CIAnalyticsHelper sendScreen:@"Museum News"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)navLeftButtonDidPress:(id)sender {
    [self performSegueWithIdentifier:@"exitMuseumNews" sender:self];
}

- (void)viewWillAppear:(BOOL)animated {
    // Show the navigation bar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (IBAction)segueGoMuseumNews:(UIStoryboardSegue *)segue {
}

#pragma mark - Webview delegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    // Show error view
    [webView removeFromSuperview];
    errorView.hidden = NO;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        requestURL = [[request URL] absoluteString];
        [self performSegueWithIdentifier:@"showBrowser" sender:self];
        return NO;
    }
    
    return YES;
}

- (IBAction)visitDidPress:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://carnegiemuseums.org"]];
}

#pragma mark - Transition

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showBrowser"]) {
        CIBrowserViewController *browserViewController = (CIBrowserViewController *)segue.destinationViewController;
        browserViewController.parentMode = @"museumNews";
        browserViewController.viewTitle = @"Museum News";
        browserViewController.url = requestURL;
    }
}

@end
