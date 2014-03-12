//
//  CIArtworkPhotoCell.h
//  International
//
//  Created by Dimitry Bentsionov on 7/24/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CIArtworkPhotoCell : UICollectionViewCell {
    UIImage *photoImage;
    UIImageView *photoImageView;
}

@property (nonatomic, retain) CIMedium *medium;

- (void)performSelectionAnimation:(BOOL)selected;

@end