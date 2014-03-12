//
//  CIArtworkTabButton.m
//  International
//
//  Created by Dimitry Bentsionov on 7/31/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIArtworkTabButton.h"

@implementation CIArtworkTabButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    // Draw line
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(currentContext);
    CGContextSetLineWidth(currentContext, 1);
    CGContextSetRGBStrokeColor(currentContext, 1.0f, 1.0f, 1.0f, 0.3f);
    CGContextBeginPath(currentContext);
    CGContextMoveToPoint(currentContext, 0, 0);
    CGContextAddLineToPoint(currentContext, 0, rect.size.height);
    CGContextStrokePath(currentContext);
    CGContextRestoreGState(currentContext);
}

@end
