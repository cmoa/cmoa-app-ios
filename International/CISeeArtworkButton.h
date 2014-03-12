//
//  CISeeArtworkButton.h
//  International
//
//  Created by Dimitry Bentsionov on 8/6/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CISeeArtworkButton : UIButton {
    UIView *sepView;
    UIView *sepView2;
}

- (void)addTopSeparator;

@end