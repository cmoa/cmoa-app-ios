//
//  CIPhotoDetailViewController.m
//  International
//
//  Created by Dimitry Bentsionov on 7/26/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import "CIArtworkPhotoDetailViewController.h"
#import "CINavigationItem.h"

@interface CIArtworkPhotoDetailViewController ()

@end

@implementation CIArtworkPhotoDetailViewController

@synthesize medium;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Configure nav button
    CINavigationItem *navItem = (CINavigationItem *)self.navigationItem;
    [navItem setLeftBarButtonType:CINavigationItemLeftBarButtonTypeBack target:self action:@selector(navLeftButtonDidPress:)];
    
    // Set the title
    CIArtwork *artwork = self.medium.artwork;
    self.title = artwork.title;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineSpacing = 1.0f;
    NSMutableAttributedString *strTitle = [[NSMutableAttributedString alloc] initWithString:medium.title];
    [strTitle addAttribute:NSFontAttributeName
                     value:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]
                     range:NSMakeRange(0, [medium.title length])];
    [strTitle addAttribute:NSForegroundColorAttributeName
                     value:[UIColor colorFromHex:kCIBlackTextColor]
                     range:NSMakeRange(0, [medium.title length])];
    [strTitle addAttribute:NSParagraphStyleAttributeName
                     value:paragraphStyle
                     range:NSMakeRange(0, [medium.title length])];
    lblTitle.attributedText = strTitle;
    
    // Configure the scrollview
    photoScrollView.contentMode = UIViewContentModeScaleAspectFill;
    photoScrollView.maximumZoomScale = 5;
    photoScrollView.minimumZoomScale = 1;
    photoScrollView.clipsToBounds = YES;
    
    // Setup the photo view
    photoView = [[UIImageView alloc] init];
    [photoScrollView addSubview:photoView];
    
    // Load the photo
    // We should have the small version already loaded locally
    NSString *fileUrl = self.medium.urlSmall;
    NSString *filePath = [CIMedium getFilePathForUrl:fileUrl];
    photoImage = [UIImage imageWithContentsOfFile:filePath];
    photoView.image = photoImage;
    // Load large one
    [self loadPhoto];
    
    // Double tap
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [tapRecognizer setNumberOfTapsRequired:2];
    [photoScrollView addGestureRecognizer:tapRecognizer];
}

- (void)viewDidAppear:(BOOL)animated {
    // Analytics
    [CIAnalyticsHelper sendEvent:@"ArtworkPhotoDetail"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)navLeftButtonDidPress:(id)sender {
    [self performSegueWithIdentifier:@"showArtworkDetail" sender:self];
}

- (void)viewDidLayoutSubviews {
    // Position image
    CGFloat width, ratio, height;
    CGFloat margin = 30.0f;
    if ([self.medium.width floatValue] >= [self.medium.height floatValue]) {
        width = photoScrollView.frame.size.width - margin;
        ratio = [self.medium.width floatValue] / width;
        height = roundf([self.medium.height floatValue] / ratio);
    } else {
        height = photoScrollView.frame.size.height - margin;
        ratio = [self.medium.height floatValue] / height;
        width = roundf([self.medium.width floatValue] / ratio);
    }
    photoView.bounds = (CGRect){CGPointZero, {width, height}};
    photoView.center = (CGPoint){photoScrollView.frame.size.width / 2.0f, photoScrollView.frame.size.height / 2.0f};
}

- (void)loadPhoto {
    // Find photo path (locally)
    NSString *fileUrl = self.medium.urlLarge;
    NSString *filePath = [CIMedium getFilePathForUrl:fileUrl];
    NSString *dirPath = [CIMedium getDirectoryPathForUrl:fileUrl];
    photoImage = [UIImage imageWithContentsOfFile:filePath];
    // Find if we already have a cached photo
    if (photoImage) {
        // Apply to the image view
        if (photoView != nil) {
            photoView.image = photoImage;
        }
    } else {
        // Load large photo
        NSURL *url = [NSURL URLWithString:fileUrl];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            if (image != nil) {
                // Apply to the profile image view (in main thread)
                dispatch_async(dispatch_get_main_queue(), ^() {
                    // Check if cell has been reused
                    if ([fileUrl isEqualToString:self.medium.urlLarge] == NO) {
                        return;
                    }
                    
                    // Apply to the image view
                    if (photoView != nil) {
                        photoView.image = image;
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

#pragma mark - Scrollview delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return photoView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // Center the photo view
    CGSize boundsSize = photoScrollView.bounds.size;
    CGRect contentsFrame = photoView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    photoView.frame = contentsFrame;
}

#pragma mark - Double tap

- (void)handleDoubleTap:(UIGestureRecognizer*)gesture {
    if (photoScrollView.zoomScale > photoScrollView.minimumZoomScale) {
        [photoScrollView setZoomScale:photoScrollView.minimumZoomScale animated:YES];
    } else {
        [photoScrollView setZoomScale:photoScrollView.maximumZoomScale animated:YES];
    }
}

@end