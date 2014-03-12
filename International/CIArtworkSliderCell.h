//
//  CIArtworkSliderCell.h
//  International
//
//  Created by Dimitry Bentsionov on 7/26/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CIArtworkSliderCell : UICollectionViewCell {
    UIImage *photoImage;
    UIImageView *photoImageView;
}

@property (nonatomic, retain) CIMedium *medium;

- (void)performSelectionAnimation:(BOOL)selected;

@end