//
//  CINavigationItem.h
//  International
//
//  Created by Dimitry Bentsionov on 7/23/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    CINavigationItemLeftBarButtonTypeBack = 2
};
typedef NSUInteger CINavigationItemLeftBarButtonType;

enum {
    CINavigationItemRightBarButtonTypeDone = 1,
    CINavigationItemRightBarButtonTypeOpenInSafari = 3,
    CINavigationItemRightBarButtonTypeSocial = 4
};
typedef NSUInteger CINavigationItemRightBarButtonType;

@interface CINavigationItem : UINavigationItem

- (void)setLeftBarButtonType:(CINavigationItemLeftBarButtonType)type target:(id)target action:(SEL)action;
- (void)setRightBarButtonType:(CINavigationItemRightBarButtonType)type target:(id)target action:(SEL)action;

@end