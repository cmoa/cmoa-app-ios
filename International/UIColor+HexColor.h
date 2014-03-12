//
//  UIColor+HexColor.h
//  International
//
//  Created by Dimitry Bentsionov on 7/4/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexColor)

+ (UIColor *)colorFromHex:(NSString *)hexColor;
+ (UIColor *)colorFromHex:(NSString *)hexColor alpha:(CGFloat)alpha;
- (UIColor *)lighterColor;
- (UIColor *)darkerColor;

@end