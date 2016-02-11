//
//  CIWelcomeViewController.m
//  International
//
//  Created by Dimitry Bentsionov on 7/9/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIImage+SVG/UIImage+SVG.h>

#import "CIWelcomeViewController.h"
#import "CIAPIRequest.h"
#import "UIImage+Resize.h"
#import "MBProgressHUD.h"
#import "CIArtworkCodeViewController.h"
#import "CINavigationController.h"
#import "UIImage+ImageEffects.h"

@interface CIWelcomeViewController ()

@end

@implementation CIWelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [self loadThemeImage];
    
    // Set Exhibitions as selected
    if (IS_IPAD) {
        btnExhibitions.selected = YES;
    }
}

- (void)loadThemeImage {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(deletedAt = nil) AND (isLive = YES)"];
    NSArray *exhibitions = [CIExhibition MR_findAllSortedBy:@"position" ascending:YES withPredicate:predicate];
    
    NSUInteger totalExhibitions = [exhibitions count];
    
    CGFloat offset;
    UIImage *themeImage;
    UIImage *themeImageBlurred;
    
    if (IS_IPHONE) {
        offset = themeImageViewBlurred.frame.size.height / themeImageView.frame.size.height;
        themeImageViewBlurred.layer.contentsRect = CGRectMake(0, offset, 1, 1);
        
    } else {
        offset = 0.1;
        
        themeImageView.layer.contentsRect = CGRectMake(offset, 0, 1, 1);
        themeImageViewBlurred.layer.contentsRect = CGRectMake(offset, 0, 1, 1);
    }
    
    if (totalExhibitions != 0) {
        NSUInteger randomNumber = arc4random() % totalExhibitions;
        CIExhibition *exhibition = [exhibitions objectAtIndex:randomNumber];
        
        themeImage = [UIImage imageWithContentsOfFile:[exhibition getBackgroundFilePath]];
        themeImageBlurred = [UIImage imageWithContentsOfFile:[exhibition getBlurredBackgroundFilePath]];
    } else {
        if (IS_IPHONE) {
            themeImage = [UIImage imageNamed:@"welcome_bg_iPhone.png"];
            themeImageBlurred = [UIImage imageNamed:@"welcome_bg_iPhone_blur.png"];
        } else {
            themeImage = [UIImage imageNamed:@"welcome_bg_iPad.png"];
            themeImageBlurred = [UIImage imageNamed:@"welcome_bg_iPad_blur.png"];
        }
    }
    
    themeImageView.image = themeImage;
    themeImageViewBlurred.image = themeImageBlurred;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    // Analytics
    [CIAnalyticsHelper sendEvent:@"AppStart"];
    [self runSync];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)segueGoHome:(UIStoryboardSegue *)segue {
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Deselect all buttons
    for (UIView *view in navContainer.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [(UIButton *)view setSelected:NO];
        }
    }
    
    if ([segue.identifier isEqualToString:@"showArtworkCode"]) {
        if (IS_IPHONE) {
            CIArtworkCodeViewController *artworkCodeViewController = (CIArtworkCodeViewController *)segue.destinationViewController;
            artworkCodeViewController.parentMode = @"home";
        } else if (IS_IPAD) {
            CINavigationController *artworkCodeViewParentController = (CINavigationController *)segue.destinationViewController;
            CIArtworkCodeViewController *artworkCodeViewController = (CIArtworkCodeViewController *)artworkCodeViewParentController.topViewController;
            artworkCodeViewController.parentMode = @"home";
        }
    } else if ([segue.identifier isEqualToString:@"showVisit"]) {
        btnMyVisit.selected = YES;
    } else if ([segue.identifier isEqualToString:@"showExhibitionList"]) {
        btnExhibitions.selected = YES;
    } else if ([segue.identifier isEqualToString:@"showMuseumNews"]) {
        btnMuseumNews.selected = YES;
    } else if ([segue.identifier isEqualToString:@"showCMOATV"]) {
        btnCMOATV.selected = YES;
    } else if ([segue.identifier isEqualToString:@"showConnect"]) {
        btnConnect.selected = YES;
    }
}

#pragma mark - Sync

- (void)runSync {
    // Check if we're doing a full sync (first launch or after version was updated)
    // Doing a quick check on artwork count
    NSArray *artworks = [CIArtwork MR_findAll];

    CIAPIRequest *apiRequest = [[CIAPIRequest alloc] init];
    if ([artworks count] == 0) {
        // Show HUD
        MBProgressHUD *hud;
        if (IS_IPHONE) {
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
        } else {
            UIViewController *detailViewController = [self.splitViewController.viewControllers objectAtIndex:1];
            hud = [MBProgressHUD showHUDAddedTo:detailViewController.view animated:YES];
        }
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"Updating Exhibition Content";
        hud.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];

        // Sync
        [apiRequest syncAll:YES
                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                        if ([self haveBackgroundsToDownload]) {
                            [hud hide:YES];
                            [self downloadExhibitionsBackgrounds];
                        } else {
                            if (IS_IPAD) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"DidFinishSync"
                                                                                    object:self];
                            }
                            
                            [hud hide:YES];
                        }
        }
                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//                        NSLog(@"Sync Failure: %@ %@", error, JSON);
                        [hud hide:YES];
        }];
    } else {
        // Incremental sync
        [apiRequest syncAll:NO
                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                        if ([self haveBackgroundsToDownload]) {
                            [self downloadExhibitionsBackgrounds];
                        } else {
                            if (IS_IPAD) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"DidFinishSync"
                                                                                    object:self];
                            }
                        }
                    }
                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//            NSLog(@"Sync Failure: %@ %@", error, JSON);
        }];
    }
}

#pragma mark - Exhibition bg download

- (BOOL)haveBackgroundsToDownload {
    // Find exhibitions to download
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(bgDownloaded = NO)"];
    NSArray *exhibitions = [CIExhibition MR_findAllWithPredicate:predicate];
    return ([exhibitions count] > 0);
}

- (void)downloadExhibitionsBackgrounds {
    // Find exhibitions to download
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(bgDownloaded = NO)"];
    exhibitionsToDownload = [NSMutableArray arrayWithArray:[CIExhibition MR_findAllWithPredicate:predicate]];
    
    // Show HUD
    MBProgressHUD *hud;
    if (IS_IPHONE) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
    } else {
        UIViewController *detailViewController = [self.splitViewController.viewControllers objectAtIndex:1];
        hud = [MBProgressHUD showHUDAddedTo:detailViewController.view animated:YES];
    }
    hud.mode = MBProgressHUDModeDeterminate;
    hud.labelText = @"Downloading Exhibition";
    hud.labelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
    
    // Calculate total download size
    totalDownloadSize = 0.0f;
    totalDownloadedSize = 0.0f;
    for (CIExhibition *exhibition in exhibitionsToDownload) {
        if (IS_IPHONE) {
            totalDownloadSize += [exhibition.bgIphoneFileSize floatValue];
        } else {
            totalDownloadSize += [exhibition.bgIpadFileSize floatValue];
        }
    }
    
    // Download image
    CIExhibition *exhibition = [exhibitionsToDownload objectAtIndex:0];
    [exhibitionsToDownload removeObjectAtIndex:0];
    [self downloadBackgroundsForExhibition:exhibition hud:hud];
}

- (void)downloadBackgroundsForExhibition:(CIExhibition *)exhibition hud:(MBProgressHUD *)hud {
    // Figure out which file to download
    NSString *fileUrl;
    if (IS_IPHONE) {
        fileUrl = exhibition.bgIphoneRetina;
    } else {
        fileUrl = exhibition.bgIpadRetina;
    }
    
    // Find local paths
    NSString *filePath = [exhibition getBackgroundFilePath];
    NSString *dirPath = [exhibition getDirectoryPath];
    
    // Start the download
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:fileUrl]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        // Update progress
        hud.progress = (totalDownloadedSize + (float)totalBytesRead) / (float)totalDownloadSize;
    }];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Verify that image cache directory exists
        if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
            NSError *error;
            [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
        }
        
        // Resize image if non-retina
        CGFloat scale = [UIScreen mainScreen].scale;
        NSData *responseData = responseObject;
        UIImage *image = [UIImage imageWithData:responseData scale:scale];
        if (scale < 2.0f) {
            image = [image resizedImage:(CGSize){image.size.width / 2.0f, image.size.height / 2.0f} interpolationQuality:kCGInterpolationDefault];
        }
        
        // Cache image
        [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
        
        // Get blurred image and cache it
        UIImage *blurred = [image applyCustomEffect];
        NSString *filePathBlurred = [exhibition getBlurredBackgroundFilePath];
        [UIImagePNGRepresentation(blurred) writeToFile:filePathBlurred atomically:YES];
        
        // Make sure these files aren't backed up by iCloud
        [CIFileHelper addSkipBackupAttributeToItemAtURLstring:filePath];
        [CIFileHelper addSkipBackupAttributeToItemAtURLstring:filePathBlurred];
        
        // Save downloaded bytes
        totalDownloadedSize += (CGFloat)responseData.length;
        
        // Update exhibition
        exhibition.bgDownloaded = @YES;

        // Download next
        if ([exhibitionsToDownload count] > 0) {
            CIExhibition *nextExhibition = [exhibitionsToDownload objectAtIndex:0];
            [exhibitionsToDownload removeObjectAtIndex:0];
            [self downloadBackgroundsForExhibition:nextExhibition hud:hud];
        } else {
            // Save data context
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            
            // Hide HUD
            [hud hide:YES];
            
            // Sync finished notification
            if (IS_IPAD) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"DidFinishSync"
                                                                    object:self];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error %@", error);
        // TODO: How to handle? Use default image for exhibition background?
    }];
    [operation start];
}

@end