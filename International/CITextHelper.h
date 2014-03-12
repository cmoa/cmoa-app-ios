//
//  CITextHelper.h
//  International
//
//  Created by Dimitry Bentsionov on 8/5/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <Foundation/Foundation.h>

// Font size constants
typedef enum {
    CITextBodyFontSizeIndexSmall      = 0,
    CITextBodyFontSizeIndexMedium     = 1,
    CITextBodyFontSizeIndexLarge      = 2,
    CITextBodyFontSizeIndexExtraLarge = 3
} CITextBodyFontSizeIndex;

#define kCIFontResizeThreshhold 0.4f

@interface CITextHelper : NSObject

+ (NSAttributedString *)attributedStringFromMarkdown:(NSString *)markdown;
+ (NSAttributedString *)attributedStringFromMarkdown:(NSString *)markdown fontSize:(CGFloat)fontSize;
+ (NSString*)artistsJoinedByComa:(NSArray*)artists;

+ (CGFloat)getTextBodyFontSizeWithIndex:(CITextBodyFontSizeIndex)fontSizeIndex;
+ (void)setTextBodyFontSize:(CITextBodyFontSizeIndex)fontSizeIndex;
+ (CITextBodyFontSizeIndex)getTextBodyFontSizeIndex;

@end