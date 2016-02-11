//
//  CIAudioView.h
//  International
//
//  Created by Dimitry Bentsionov on 7/29/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AFNetworking.h"
#import "CIBorderedButton.h"

@protocol CIAudioViewDelegate;

@interface CIAudioView : UIView {
    UIView *progressEmptyView;
    UIView *progressFullView;
    CIBorderedButton *btnPlay;
    UIButton *btnInfo;
    CIBorderedButton *btnMore;
    UIView *sepView;
    BOOL showMoreButton;
    
    // Network
    AFURLConnectionOperation *operation;
    
    // Audio
    BOOL isDownloading;
    BOOL isPlaying;
    BOOL forceHideMore;
    AVPlayer *audioPlayer;
    AVPlayerItem *playerItem;
    CGFloat totalTime;
    CGFloat currTime;
    id timeObserver;
}

@property (nonatomic) CGFloat progress;
@property (nonatomic, retain) CIMedium *medium;
@property (nonatomic, retain) id<CIAudioViewDelegate> delegate;
@property (nonatomic) CGFloat totalTime;
@property (nonatomic) CGFloat currTime;
@property (nonatomic) BOOL isDownloading;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) BOOL forceHideMore;

- (void)cleanUp;

@end

@protocol CIAudioViewDelegate <NSObject>
@optional
- (void)audioViewMoreDidPress:(CIAudioView *)audioView medium:(CIMedium *)medium;
@end