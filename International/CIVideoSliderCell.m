//
//  CIVideoSliderCell.m
//  International
//
//  Created by Dimitry Bentsionov on 8/8/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIVideoSliderCell.h"
#import "AFNetworking.h"

#define MAX_HEIGHT 160

@implementation CIVideoSliderCell

@synthesize medium = _medium;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Photo image container
//        UIImage *image = [UIImage imageNamed:@"button_video_on"];
        photoImageView = [[UIImageView alloc] init];
        photoImageView.backgroundColor = [UIColor colorFromHex:@"#cccccc"];
        photoImageView.image = photoImage;
        photoImageView.alpha = 0.0f;
        [self addSubview:photoImageView];
        
        // If photo is already loaded
        if (photoImage != nil) {
            [UIView animateWithDuration:0.3f animations:^{
                photoImageView.alpha = 1.0f;
            }];
        }
        
        // Overlay image container
        overlayImageView = [[UIImageView alloc] init];
        UIImage *image = [UIImage imageNamed:@"button_video_on"];
        overlayImageView.image = image;
        overlayImageView.bounds = (CGRect){CGPointZero, image.size};
        [self addSubview:overlayImageView];
    }
    return self;
}

- (void)prepareForReuse {
    // Refresh image view
    photoImageView.image = nil;
}

- (void)setMedium:(CIMedium *)medium {
    _medium = medium;
    
    // Resize the photo image view
    CGFloat ratio = [medium.height floatValue] / (float)MAX_HEIGHT;
    CGFloat width = roundf([medium.width floatValue] / ratio);
    photoImageView.bounds = (CGRect){CGPointZero, {width, MAX_HEIGHT}};
    photoImageView.center = (CGPoint){self.frame.size.width / 2.0f, self.frame.size.height / 2.0f};
    overlayImageView.center = (CGPoint){self.frame.size.width / 2.0f, self.frame.size.height / 2.0f};

    // Load the photo
    [self loadPhoto];
}

#pragma mark - Load photo

- (void)loadPhoto {
    // Find photo path (locally)
    NSString *fileUrl = self.medium.urlSmall;
    NSString *filePath = [CIMedium getFilePathForUrl:fileUrl];
    NSString *dirPath = [CIMedium getDirectoryPathForUrl:fileUrl];
    photoImage = [UIImage imageWithContentsOfFile:filePath];
    
    // Find if we already have a cached photo
    if (photoImage) {
        // Apply to the image view
        if (photoImageView != nil) {
            photoImageView.image = photoImage;
            [UIView animateWithDuration:0.3f animations:^{
                photoImageView.alpha = 1.0f;
            }];
        }
    } else {
        // Load small photo
        NSURL *url = [NSURL URLWithString:fileUrl];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            if (image != nil) {
                // Apply to the profile image view (in main thread)
                dispatch_async(dispatch_get_main_queue(), ^() {
                    // Check if cell has been reused
                    if ([fileUrl isEqualToString:self.medium.urlSmall] == NO) {
                        return;
                    }
                    
                    // Apply to the image view
                    if (photoImageView != nil) {
                        photoImageView.image = image;
                        [UIView animateWithDuration:0.3f animations:^{
                            photoImageView.alpha = 1.0f;
                        }];
                    }
                    
                    // Cache image locally (first verify directory exists)
                    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
                        NSError *error;
                        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
                    }
                    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
                    [imageData writeToFile:filePath atomically:YES];
                    
                    // Make sure this file isn't backed up by iCloud
                    [CIFileHelper addSkipBackupAttributeToItemAtURLstring:filePath];
                });
            }
        });
    }
}

#pragma mark - Selection/deselection handlers

- (void)performSelectionAnimation:(BOOL)selected {
    if (selected) {
        self.alpha = 0.5f;
        [UIView animateWithDuration:0.3f animations:^{
            self.alpha = 1.0f;
        }];
    } else {
        [UIView animateWithDuration:0.3f animations:^{
            self.alpha = 1.0f;
        }];
    }
}

@end