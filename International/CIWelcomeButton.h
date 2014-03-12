//
//  CIWelcomeButton.h
//  International
//
//  Created by Dimitry Bentsionov on 7/22/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CIWelcomeButton : UIButton {
    UIView *sepView;
    BOOL isSeparatorOnTop;
}

- (void)setSeparatorOnBottom;

@end