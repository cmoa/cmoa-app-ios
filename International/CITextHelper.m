//
//  CITextHelper.m
//  International
//
//  Created by Dimitry Bentsionov on 8/5/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CITextHelper.h"
#import "NSAttributedStringMarkdownParser.h"

@implementation CITextHelper

+ (NSAttributedString *)attributedStringFromMarkdown:(NSString *)markdown {
    return [CITextHelper attributedStringFromMarkdown:markdown fontSize:13.0f];
}

+ (NSAttributedString *)attributedStringFromMarkdown:(NSString *)markdown fontSize:(CGFloat)fontSize {
    // Count non-standard characters
    NSUInteger length = [markdown length];
    NSUInteger totalNonStandardCharacters = 0;
    for(int i=0; i<length; i++) {
        if ([markdown characterAtIndex:i] > 127) {
            totalNonStandardCharacters++;
        }
    }
    totalNonStandardCharacters += 20; // Hacky. Above doesn't always capture all characters. We will trim them later.
    
    // Make string with spaces (to pad the original text)
    NSMutableString *padding = [[NSMutableString alloc] init];
    for(int i=0; i<totalNonStandardCharacters; i++) {
        [padding appendString:@" "];
    }
    
    // Add padded spaces to the end of the string
    markdown = [NSString stringWithFormat:@"%@%@", markdown, padding];
    
    // Define paragraph style
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineSpacing = 3.0f;
    
    // Parse
    NSAttributedStringMarkdownParser *parser = [[NSAttributedStringMarkdownParser alloc] init];
    parser.paragraphFont = [UIFont fontWithName:@"HelveticaNeue" size:fontSize];
    parser.boldFontName = @"HelveticaNeue-Bold";
    parser.italicFontName = @"HelveticaNeue-Italic";
    parser.boldItalicFontName = @"HelveticaNeue-BoldItalic";
    
    // Add color to text
    NSAttributedString *immutableStr = [parser attributedStringFromMarkdownString:markdown];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:immutableStr];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorFromHex:@"#556270"] range:NSMakeRange(0, [string length])];
    [string addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [string length])];
    
    // Trim whitespace
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSRange range = [[string string] rangeOfCharacterFromSet:set options:NSBackwardsSearch];
    while (range.length != 0 && NSMaxRange(range) == [string length]) {
        [string replaceCharactersInRange:range withString:@""];
        range = [[string string] rangeOfCharacterFromSet:set options:NSBackwardsSearch];
    }
    
    return [[NSAttributedString alloc] initWithAttributedString:string];
}

+ (NSString*)artistsJoinedByComa:(NSArray*)artists {
    NSMutableArray *artistNames = [NSMutableArray arrayWithCapacity:[artists count]];
    for (CIArtist *artist in artists) {
        [artistNames addObject:artist.name];
    }
    
    return [artistNames componentsJoinedByString:@", "];
}

+ (CGFloat)getTextBodyFontSizeWithIndex:(CITextBodyFontSizeIndex)fontSizeIndex {
    NSArray *fontSizes = @[@11, @13, @15, @17];
    return [[fontSizes objectAtIndex:fontSizeIndex] floatValue];
}

+ (void)setTextBodyFontSize:(CITextBodyFontSizeIndex)fontSizeIndex {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:fontSizeIndex] forKey:kCITextBodyFontSizeIndex];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (CITextBodyFontSizeIndex)getTextBodyFontSizeIndex {
    NSNumber *bodyFontSizeIndexObj = [[NSUserDefaults standardUserDefaults] objectForKey:kCITextBodyFontSizeIndex];
    if (bodyFontSizeIndexObj == nil) {
        return CITextBodyFontSizeIndexMedium;
    } else {
        return [bodyFontSizeIndexObj intValue];
    }
    
}

@end