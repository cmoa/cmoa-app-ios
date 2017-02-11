//
//  CIArtworkPhotosViewController.h
//  International
//
//  Created by Dimitry Bentsionov on 7/24/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTCollectionViewWaterfallLayout.h"

@interface CIArtworkPhotosViewController : UIViewController <UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout> {
    IBOutlet UICollectionView *photosCollectionView;
    NSArray *artworks;
    NSMutableArray *photos;
    CGFloat cellWidth;
}

@end