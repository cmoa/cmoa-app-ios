//
//  CIMuseumVideosViewController.h
//  International
//
//  Created by Dimitry Bentsionov on 8/6/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CIMuseumVideosViewController : UIViewController {
    IBOutlet UIWebView *videosWebView;
    IBOutlet UIView *errorView;
    NSString *requestURL;
}

@end