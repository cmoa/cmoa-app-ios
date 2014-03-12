//
//  CIPhotoDetailViewController.h
//  International
//
//  Created by Dimitry Bentsionov on 7/26/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CIArtworkPhotoDetailViewController : UIViewController <UIScrollViewDelegate> {
    IBOutlet UILabel *lblTitle;
    IBOutlet UIScrollView *photoScrollView;
    UIImageView *photoView;
    UIImage *photoImage;
}

@property (nonatomic, retain) CIMedium *medium;

@end