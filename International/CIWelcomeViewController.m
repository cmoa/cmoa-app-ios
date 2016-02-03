//
//  CIWelcomeViewController.m
//  International
//
//  Created by Dimitry Bentsionov on 7/9/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
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
    
    // Device height detect
    is4InchiPhone = [UIScreen mainScreen].bounds.size.height == 568;
    
    // Background & nav bar hidden
    if (IS_IPHONE) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            headerImage.image = [UIImage imageNamed:@"welcome_header"]; // Default: welcome_header_nobar
            conSearchButton.constant = 30.0f; // Includes top bar (20px)
            if (is4InchiPhone) {
                self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"welcome_bg-h568"]];
            } else {
                self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"welcome_bg"]];
            }
        } else {
            if (is4InchiPhone) {
                self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"welcome_bg_nobar-h568"]];
            } else {
                self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"welcome_bg_nobar"]];
            }
        }
    } else if (IS_IPAD) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            headerImage.image = [UIImage imageNamed:@"welcome_header"]; // Default: welcome_header_nobar
            conSearchButton.constant = conSearchButton.constant + 20.0f; // Includes top bar (20px)
            conNavContainer.constant = conNavContainer.constant + 20.0f; // Includes top bar (20px)
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"welcome_bg-h748"]];
        } else {
            self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"welcome_bg_nobar-h748"]];
        }
    }
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    // Set button separators on the bottom for iPad
    if (IS_IPAD) {
        for (CIWelcomeButton *button in navContainer.subviews) {
            [button setSeparatorOnBottom];
        }
    }
    
    // Set Exhibitions as selected
    if (IS_IPAD) {
        btnExhibitions.selected = YES;
    }
}

- (void)viewDidLayoutSubviews {
    UIImage *bgImage;
    if (IS_IPHONE) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            if (is4InchiPhone) {
                bgImage = [UIImage imageNamed:@"welcome_bg_blur-h568"];
            } else {
                bgImage = [UIImage imageNamed:@"welcome_bg_blur"];
            }
        } else {
            if (is4InchiPhone) {
                bgImage = [UIImage imageNamed:@"welcome_bg_nobar_blur-h568"];
            } else {
                bgImage = [UIImage imageNamed:@"welcome_bg_nobar_blur"];
            }
        }
    } else if (IS_IPAD) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            bgImage = [UIImage imageNamed:@"welcome_bg_blur-h748"];
        } else {
            bgImage = [UIImage imageNamed:@"welcome_bg_nobar_blur-h748"];
        }
    }

    // Header background
    CGFloat scale = [UIScreen mainScreen].scale;
    CGRect crop = (CGRect){{headerImage.frame.origin.x * scale, headerImage.frame.origin.y * scale}, {headerImage.frame.size.width * scale, headerImage.frame.size.height * scale}};
    headerImage.backgroundColor = [UIColor colorWithPatternImage:[bgImage croppedImage:crop]];
    headerImage.layer.rasterizationScale = scale;
    headerImage.layer.shouldRasterize = YES;

    // Nav container background
    crop = (CGRect){{navContainer.frame.origin.x * scale, navContainer.frame.origin.y * scale}, {navContainer.frame.size.width * scale, navContainer.frame.size.height * scale}};
    navContainer.backgroundColor = [UIColor colorWithPatternImage:[bgImage croppedImage:crop]];
    navContainer.layer.rasterizationScale = scale;
    navContainer.layer.shouldRasterize = YES;
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
    for (CIWelcomeButton *button in navContainer.subviews) {
        button.selected = NO;
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

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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