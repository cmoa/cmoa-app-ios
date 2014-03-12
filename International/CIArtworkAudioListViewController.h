//
//  CIArtworkAudioListViewController.h
//  International
//
//  Created by Dimitry Bentsionov on 8/1/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CIArtworkAudioListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSArray *media;
    IBOutlet UITableView *audioTableView;
}

@property (nonatomic, retain) CIArtwork *artwork;

@end