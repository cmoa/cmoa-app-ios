//
//  CITabBar.m
//  CMOA
//
//  Created by Dimitry Bentsionov on 8/13/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CITabBar.h"

@implementation CITabBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self postInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self postInit];
    }
    return self;
}

- (void)postInit {
    // Customize appearance
    NSDictionary *normalState = @{
                                  UITextAttributeFont : [UIFont fontWithName:@"HelveticaNeue-Medium" size:9.0f],
                                  UITextAttributeTextColor : [UIColor colorFromHex:@"#929292"],
                                  UITextAttributeTextShadowColor: [UIColor clearColor],
                                  UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0.0, 0.0)]
                                  };
    
    NSDictionary *selectedState = @{
                                    UITextAttributeFont : [UIFont fontWithName:@"HelveticaNeue-Medium" size:9.0f],
                                    UITextAttributeTextColor : [UIColor colorFromHex:kCILinkColor],
                                    UITextAttributeTextShadowColor: [UIColor clearColor],
                                    UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0.0, 0.0)]
                                    };
    
    [[UITabBarItem appearance] setTitleTextAttributes:normalState forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:selectedState forState:UIControlStateSelected];
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor redColor]];
//    [[UITabBar appearance] setSelectionIndicatorImage:[[UIImage alloc] init]];
    
    // Set images for each item
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        [[self.items objectAtIndex:0] setFinishedSelectedImage:[UIImage imageNamed:@"tab_artwork_on"]
                                   withFinishedUnselectedImage:[UIImage imageNamed:@"tab_artwork_off"]];
        [[self.items objectAtIndex:1] setFinishedSelectedImage:[UIImage imageNamed:@"tab_title_on"]
                                   withFinishedUnselectedImage:[UIImage imageNamed:@"tab_title_off"]];
        [[self.items objectAtIndex:2] setFinishedSelectedImage:[UIImage imageNamed:@"tab_category_on"]
                                   withFinishedUnselectedImage:[UIImage imageNamed:@"tab_category_off"]];
        [[self.items objectAtIndex:3] setFinishedSelectedImage:[UIImage imageNamed:@"tab_code_on"]
                                   withFinishedUnselectedImage:[UIImage imageNamed:@"tab_code_off"]];
    } else {
        UITabBarItem *item1 = (UITabBarItem *)[self.items objectAtIndex:0];
        item1.image = [[UIImage imageNamed:@"tab_artwork_off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item1.selectedImage = [[UIImage imageNamed:@"tab_artwork_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UITabBarItem *item2 = (UITabBarItem *)[self.items objectAtIndex:1];
        item2.image = [[UIImage imageNamed:@"tab_title_off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item2.selectedImage = [[UIImage imageNamed:@"tab_title_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UITabBarItem *item3 = (UITabBarItem *)[self.items objectAtIndex:2];
        item3.image = [[UIImage imageNamed:@"tab_category_off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item3.selectedImage = [[UIImage imageNamed:@"tab_category_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UITabBarItem *item4 = (UITabBarItem *)[self.items objectAtIndex:3];
        item4.image = [[UIImage imageNamed:@"tab_code_off"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item4.selectedImage = [[UIImage imageNamed:@"tab_code_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
}

@end