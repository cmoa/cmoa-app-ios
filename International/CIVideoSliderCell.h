//
//  CIVideoSliderCell.h
//  International
//
//  Created by Dimitry Bentsionov on 8/8/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CIVideoSliderCell : UICollectionViewCell {
    UIImage *photoImage;
    UIImageView *photoImageView;
    UIImageView *overlayImageView;
}

@property (nonatomic, retain) CIMedium *medium;

- (void)performSelectionAnimation:(BOOL)selected;

@end