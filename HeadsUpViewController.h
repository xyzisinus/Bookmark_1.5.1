//
//  HeadsUpController.h
//  Bookmark
//
//  Created by Barry Ezell on 11/1/09.
//  Copyright 2009 Dockmarket LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TouchImageView.h"
#import "Work.h"
#import "PlayerViewController.h"
#import "MasterMusicPlayer.h"

@interface HeadsUpViewController : UIViewController <TouchImageViewDelegate> {	
	TouchImageView *artView;
	MasterMusicPlayer *player;
	BOOL keepingAwake;
	CGRect albumFrame;
}

@property (nonatomic, retain) MasterMusicPlayer *player;
@property (nonatomic, retain) TouchImageView *artView;
@property (nonatomic, retain) UILabel *instLabel;
@property (nonatomic, assign) BOOL showInstructions;

- (void)hideInstructions;
- (void)animateAlbumArtInX:(int)x andY:(int)y;
- (void)moveHasFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context;

@end
