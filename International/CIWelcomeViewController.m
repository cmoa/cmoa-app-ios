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
    
    // Haven't shown yet
    didShowOnce = NO;
    
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
    
    // Setup tap handler for coach marks
    [self addCoachMarksTapGesture];
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

    if (didShowOnce == NO) {
        didShowOnce = YES;
        
        [UIView animateWithDuration:0.5f animations:^{
            headerImage.alpha = 1.0f;
            navContainer.alpha = 1.0f;
            btnSearch.alpha = 1.0f;
        } completion:^(BOOL finished) {
            // Show coach marks
            [self showCoachMarks:NO];

            // Start sync process (after coach marks show)
            [self performSelector:@selector(runSync) withObject:nil afterDelay:0.5f];
        }];
    }
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
            if (coachMarksView != nil) {
                // Find coach marks view index to show HUD under it
                hud = [MBProgressHUD showHUDAddedTo:self.view belowSubview:coachMarksView animated:YES];
            } else {
                hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            }
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
        if (coachMarksView != nil) {
            // Find coach marks view index to show HUD under it
            hud = [MBProgressHUD showHUDAddedTo:self.view belowSubview:coachMarksView animated:YES];
        } else {
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        }
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

#pragma mark - Coach marks

- (void)showCoachMarks:(BOOL)forceShow {
    // Coach marks
    BOOL coachMarksShown = [[NSUserDefaults standardUserDefaults] boolForKey:kCIDidShowCoachMarks];
    if (forceShow == YES || coachMarksShown == NO) {
        // Don't show again
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kCIDidShowCoachMarks];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // Temporarily remove the gesture (so we don't accidentally trigger it again until dismissed)
        [self.view removeGestureRecognizer:coachMarksTapGesture];

        // Setup coach marks
        UIEdgeInsets padding;
        if (IS_IPAD) {
            padding = UIEdgeInsetsMake(11.0f, 8.0f, 11.0f, 8.0f);
        } else {
            padding = UIEdgeInsetsMake(4.0f, 6.0f, 4.0f, 6.0f);
        }
        CGRect rectCode;
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            rectCode = (CGRect){{263.0f, 8.0f}, {57, 50.0f}};
        } else {
            rectCode = (CGRect){{263.0f, 28.0f}, {57, 50.0f}};
        }
        CGRect rectMyVisit = [self addPaddingToRect:[navContainer convertRect:btnMyVisit.frame toView:self.view]
                                            padding:padding];
        CGRect rectExhibitions = [self addPaddingToRect:[navContainer convertRect:btnExhibitions.frame toView:self.view]
                                                padding:padding];
        CGRect rectConnect = [self addPaddingToRect:[navContainer convertRect:btnConnect.frame toView:self.view]
                                            padding:padding];
        NSArray *coachMarks = @[
                                @{
                                    @"caption": [self formatCoachMarksText:@"Welcome to the\nCarnegie Museum of Art"]
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:rectCode],
                                    @"caption": [self formatCoachMarksText:@"Look up artworks and artists by object code.\n\nCheck gallery labels for code information."]
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:rectMyVisit],
                                    @"caption": [self formatCoachMarksText:@"Plan your next visit.\n\nCreate your must-see artwork list, learn open hours or find directions."]
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:rectExhibitions],
                                    @"caption": [self formatCoachMarksText:@"Explore artworks and exhibitions."]
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:rectConnect],
                                    @"caption": [self formatCoachMarksText:@"Stay connected."]
                                    }
                                ];
        coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.view.bounds coachMarks:coachMarks];
        coachMarksView.delegate = self;
        coachMarksView.strContinue = @"Tap to Begin";
        [self.view addSubview:coachMarksView];
        
        // Show coach marks
        [coachMarksView start];
    }
}

- (CGRect)addPaddingToRect:(CGRect)rect padding:(UIEdgeInsets)padding {
    rect.origin.x = rect.origin.x + padding.left;
    rect.origin.y = rect.origin.y + padding.top;
    rect.size.width = rect.size.width - padding.left - padding.right;
    rect.size.height = rect.size.height - padding.top - padding.bottom;
    return rect;
}

- (NSAttributedString *)formatCoachMarksText:(NSString *)text {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    paragraphStyle.lineSpacing = 4.0f;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:text];
    [str addAttribute:NSFontAttributeName
                value:[UIFont fontWithName:@"HelveticaNeue-Light" size:20.0f]
                range:NSMakeRange(0, [text length])];
    [str addAttribute:NSForegroundColorAttributeName
                value:[UIColor colorFromHex:@"#ffffff"]
                range:NSMakeRange(0, [text length])];
    [str addAttribute:NSParagraphStyleAttributeName
                value:paragraphStyle
                range:NSMakeRange(0, [text length])];
    return str;
}

- (void)addCoachMarksTapGesture {
    if (coachMarksTapGesture == nil) {
        coachMarksTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coachMarksTapHandler:)];
        coachMarksTapGesture.numberOfTapsRequired = 3;
    }
    [self.view addGestureRecognizer:coachMarksTapGesture];
}

- (void)coachMarksTapHandler:(UIGestureRecognizer *)gesture {
    // Show coach marks and override defaults
    [self showCoachMarks:YES];
    
    // Also show coach marks on artwork detail page
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCIDidShowArtworkDetailCoachMarks];
}

- (void)coachMarksViewDidCleanup:(WSCoachMarksView *)coachMarksView {
    // Re-add tap gesture
    [self addCoachMarksTapGesture];
}

@end