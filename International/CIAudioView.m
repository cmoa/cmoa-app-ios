//
//  CIAudioView.m
//  International
//
//  Created by Dimitry Bentsionov on 7/29/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CIAudioView.h"

@implementation CIAudioView

@synthesize progress = _progress;
@synthesize medium = _medium;
@synthesize delegate;
@synthesize totalTime;
@synthesize currTime;
@synthesize isDownloading;
@synthesize isPlaying;
@synthesize forceHideMore;

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
    // Background
    self.backgroundColor = [UIColor whiteColor];
    
    // Vars
    isDownloading = NO;
    isPlaying = NO;
    forceHideMore = NO;
    currTime = 0.0f;
    totalTime = 0.0f;

    // Play button
    btnPlay = [CIBorderedButton buttonWithType:UIButtonTypeCustom];
    btnPlay.borderColor= [UIColor colorFromHex:kCIAccentColor];
    btnPlay.borderHighligthedColor= [UIColor colorFromHex:kCIBarUnactiveColor];
    [btnPlay setImage:[UIImage imageNamed:@"button_play_normal"] forState:UIControlStateNormal];
    [btnPlay setImage:[UIImage imageNamed:@"button_play_normal_on"] forState:UIControlStateHighlighted];
    btnPlay.translatesAutoresizingMaskIntoConstraints = NO;
    [btnPlay addTarget:self action:@selector(btnPlayDidPress:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnPlay];
    
    // Progress bar
    progressEmptyView = [[UIView alloc] init];
    progressEmptyView.backgroundColor = [UIColor colorFromHex:@"#e5e5e5"];
    progressEmptyView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:progressEmptyView];
    progressFullView = [[UIView alloc] init];
    progressFullView.backgroundColor = [UIColor colorFromHex:@"#cccccc"];
    progressFullView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:progressFullView];
    
    // Info button
    btnInfo = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnInfo setImage:[UIImage imageNamed:@"button_info_normal"] forState:UIControlStateNormal];
    [btnInfo setImage:[UIImage imageNamed:@"button_info_normal_on"] forState:UIControlStateHighlighted];
    btnInfo.translatesAutoresizingMaskIntoConstraints = NO;
    [btnInfo addTarget:self action:@selector(btnInfoDidPress:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnInfo];
    
    // More button
    btnMore = [CIBorderedButton buttonWithType:UIButtonTypeCustom];
    btnMore.borderColor= [UIColor colorFromHex:kCIAccentColor];
    btnMore.borderHighligthedColor= [UIColor colorFromHex:kCIBarUnactiveColor];
    [btnMore setTitle:@"More" forState:UIControlStateNormal];
    [btnMore setTitleColor:[UIColor colorFromHex:kCIAccentColor] forState:UIControlStateNormal];
    [btnMore setTitleColor:[UIColor colorFromHex:kCIBarUnactiveColor] forState:UIControlStateHighlighted];
    btnMore.translatesAutoresizingMaskIntoConstraints = NO;
    [btnMore addTarget:self action:@selector(btnMoreDidPress:) forControlEvents:UIControlEventTouchUpInside];
    btnMore.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
    [self addSubview:btnMore];
    
    // Sep line
    sepView = [[UIView alloc] init];
    sepView.backgroundColor = [UIColor colorFromHex:@"#e0e0e0"];
    sepView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:sepView];
    
    // No progress by default
    self.progress = 0.0f;
    
    // Rasterize
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.layer.shouldRasterize = YES;
    
    // Global player observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioViewWillStartPlay:)
                                                 name:@"AudioViewWillStartPlay"
                                               object:nil];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Update the constaints
    [self setNeedsUpdateConstraints];
}

- (void)layoutProgress {
    // Progress bar size
    CGFloat width = roundf(progressEmptyView.frame.size.width * (self.progress / 100.0f));
    progressFullView.frame = (CGRect){progressEmptyView.frame.origin, {width, progressEmptyView.frame.size.height}};
}

- (void)setProgress:(CGFloat)progress {
    _progress = roundf(progress);
    
    // Redraw progress (on main thread)
    [self performSelectorOnMainThread:@selector(layoutProgress) withObject:self waitUntilDone:YES];
}

- (void)setMedium:(CIMedium *)medium {
    _medium = medium;
    
    // Don't show 'More' button if only one audio
    CIArtwork *artwork = medium.artwork;
    NSArray *audio = [artwork audio];
    showMoreButton = [audio count] > 1;
    if (forceHideMore == YES) {
        showMoreButton = NO;
    }
    btnMore.hidden = !showMoreButton;
}

- (void)updateConstraints {
    [super updateConstraints];
    if (CGRectIsEmpty(self.frame)) {
        return;
    }
    
    // Auto Layout
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(btnPlay, progressEmptyView, btnInfo, btnMore, sepView);
    NSArray *constraints;
    
    if (showMoreButton) {
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-[btnPlay(34)]-[progressEmptyView][btnInfo][btnMore(44)]-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:viewsDictionary];
    } else {
        constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-[btnPlay(34)]-[progressEmptyView][btnInfo]|"
                                                              options:0
                                                              metrics:nil
                                                                views:viewsDictionary];
    }
    [self addConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[btnPlay(34)]-|"
                                                          options:0
                                                          metrics:nil
                                                            views:viewsDictionary];
    [self addConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-17-[progressEmptyView]-17-|"
                                                          options:0
                                                          metrics:nil
                                                            views:viewsDictionary];
    [self addConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[btnInfo][sepView(1)]|"
                                                          options:0
                                                          metrics:nil
                                                            views:viewsDictionary];
    [self addConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[btnMore]-|"
                                                          options:0
                                                          metrics:nil
                                                            views:viewsDictionary];
    [self addConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[sepView]|"
                                                          options:0
                                                          metrics:nil
                                                            views:viewsDictionary];
    [self addConstraints:constraints];
}

- (void)cleanUp {
    // Stop network operation
    if (isDownloading) {
        operation = nil;
    }
    
    // Stop playback
    if (isPlaying) {
        // Clean up observers & audio
        [audioPlayer pause];
    }
    
    // Reset progress
    isDownloading = NO;
    isPlaying = NO;
    self.progress = 0.0f;
    [self togglePlayButtonSetPlay];
}

- (void)dealloc {
    // Clean up observers & audio
    [audioPlayer removeTimeObserver:timeObserver];
    
    @try {
        [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
        [playerItem removeObserver:self forKeyPath:@"status" context:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        [audioPlayer removeObserver:self forKeyPath:@"status" context:nil];
    } @catch(id anException) {
        // Do nothing. Just making sure observers were removed.
    }
    
    audioPlayer = nil;
}

#pragma mark - Button handling

- (void)btnMoreDidPress:(id)sender {
    if ([delegate respondsToSelector:@selector(audioViewMoreDidPress:medium:)]) {
        [delegate audioViewMoreDidPress:self medium:self.medium];
    }
}

- (void)btnPlayDidPress:(id)sender {
    // Already downloading?
    if (isDownloading) {
        // Technically, can't happen since we disable the button.
        // Leaving for possible future implementation.
        return;
    }
    
    // Already playing?
    if (isPlaying) {
        // Toggle playback if paused
        if (audioPlayer.rate == 0.0f) {
            // Notify other players
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AudioViewWillStartPlay" object:self];

            [audioPlayer play];
            [self togglePlayButtonSetPause];
        } else {
            [audioPlayer pause];
            [self togglePlayButtonSetPlay];
        }
        return;
    }
    
    // Load the content
    [self loadFile];
}

- (void)btnInfoDidPress:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ audio", self.medium.artwork.title]
                                                        message:self.medium.title
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)togglePlayButtonSetPause {
    btnPlay.enabled = YES;
    [btnPlay setImage:[UIImage imageNamed:@"button_pause_normal"] forState:UIControlStateNormal];
    [btnPlay setImage:[UIImage imageNamed:@"button_pause_normal_on"] forState:UIControlStateHighlighted];
}

- (void)togglePlayButtonSetPlay {
    btnPlay.enabled = YES;
    [btnPlay setImage:[UIImage imageNamed:@"button_play_normal"] forState:UIControlStateNormal];
    [btnPlay setImage:[UIImage imageNamed:@"button_play_normal_on"] forState:UIControlStateHighlighted];
}

#pragma mark - File loading & playing

- (void)loadFile {
    // Find photo path (locally)
    NSString *fileUrl = self.medium.urlSmall;
    NSString *filePath = [CIMedium getFilePathForUrl:fileUrl];
    NSString *dirPath = [CIMedium getDirectoryPathForUrl:fileUrl];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (fileExists) {
        // Play local file
        [self playFile];
    } else {
        // Download the file & store locally
        isDownloading = YES;
        btnPlay.enabled = NO;
        
        // Verify local dir
        if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
            NSError *error;
            [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
            if (error) {
                NSLog(@"Error: %@", error);
            }
        }
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.medium.urlFull]];
        operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
        
        // Progress
        __unsafe_unretained CIAudioView *audioView = self;
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            CGFloat percent = (float)totalBytesRead / (float)totalBytesExpectedToRead * 100.0f;
            audioView.progress = percent;
        }];
        
        [operation setCompletionBlock:^{
            // Make sure this file isn't backed up by iCloud
            [CIFileHelper addSkipBackupAttributeToItemAtURLstring:filePath];

            // Proceed to play file
            audioView.isDownloading = NO;
            [audioView performSelectorOnMainThread:@selector(playFile) withObject:nil waitUntilDone:NO];
        }];
        
        // Kick off the downloading process
        [operation start];
    }
}

- (void)playFile {
    // Notify other players
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AudioViewWillStartPlay" object:self];

    isPlaying = YES;
    [self togglePlayButtonSetPause];
    
    // Update the progress bar colors
    progressEmptyView.backgroundColor = [UIColor colorFromHex:@"#cccccc"];
    self.progress = 0.0f;
    progressFullView.backgroundColor = [UIColor colorFromHex:@"#a0cc8c"];
    
    // Find the file and play
    NSString *fileUrl = self.medium.urlSmall;
    NSString *filePath = [CIMedium getFilePathForUrl:fileUrl];
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:filePath]];
    playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
    audioPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
    [audioPlayer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
//        [audioPlayer addObserver:self forKeyPath:@"rate" options:0 context:nil];
//        [audioPlayer addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    __unsafe_unretained CIAudioView *audioView = self;
    timeObserver = [audioPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:dispatch_queue_create("com.carnegie.CMOA", NULL) usingBlock:^(CMTime time) {
        // Save current position and update the progress
        audioView.currTime = CMTimeGetSeconds(time);
        
        // Avoid dividing by 0. Race condition. Sometimes total time isn't set quite yet.
        if (audioView.totalTime != 0.0f) {
            audioView.progress = (audioView.currTime / audioView.totalTime) * 100.0f;
        }
    }];
    
    [audioPlayer play];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // Current item: loadedTimeRanges
    if (object == audioPlayer.currentItem && [keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSArray *timeRanges = (NSArray *)[change objectForKey:NSKeyValueChangeNewKey];
        if (timeRanges && [timeRanges count]) {
            // Save total time
            CMTimeRange timerange = [[timeRanges objectAtIndex:0] CMTimeRangeValue];
            totalTime = CMTimeGetSeconds(timerange.duration);
        }
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    isPlaying = NO;
    [self togglePlayButtonSetPlay];
}

#pragma mark - Global notification

- (void)audioViewWillStartPlay:(NSNotification *)notification {
    if (notification.object == self) {
        return;
    }
    
    // If we're playing, pause
    if (isPlaying && audioPlayer.rate != 0.0f) {
        [audioPlayer pause];
        [self togglePlayButtonSetPlay];
    }
}

@end