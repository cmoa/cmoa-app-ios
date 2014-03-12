//
//  CIAudioCell.h
//  International
//
//  Created by Dimitry Bentsionov on 8/2/13.
//  Copyright (c) 2013 Carnegie Museums. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CIAudioView.h"

@interface CIAudioCell : UITableViewCell {
    CIAudioView *audioView;
}

@property (nonatomic, retain) CIMedium *medium;
@property (nonatomic, retain) CIAudioView *audioView;

@end