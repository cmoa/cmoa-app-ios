//
//  CIArtworkTabLblView.m
//  International
//
//  Created by Dimitry Bentsionov on 7/31/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIArtworkTabLblView.h"

@implementation CIArtworkTabLblView

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
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    // Draw line
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, 1);
    CGContextSetRGBStrokeColor(context, 1.0f, 1.0f, 1.0f, 0.3f);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 0, rect.size.height);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

@end