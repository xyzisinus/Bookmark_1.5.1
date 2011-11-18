//
//  TimeRibbonView.h
//  TestSlider
//
//  Created by Barry Ezell on 7/8/09.
//  Copyright 2009 Dockmarket LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeStalk.h"

@protocol TimeRibbonDelegate
@required
- (void)seekBackward;
- (void)seekForward;
- (void)jump:(long)seconds;
- (void)timeRibbonEnd;
@end

@interface TimeRibbonView : UIView {	
	UIImageView *sliderView;
	UIView *stalkView;			
	bool inButtonMove;
	int buttonFingerOffset;
	id delegate;
	NSMutableArray *stalks;
	TimeStalk *raisedStalk;	
}

@property(nonatomic, assign) id<TimeRibbonDelegate> delegate;

-(void)seekForward;
-(void)seekBackward;
-(void)endSelection;
-(void)animateButtonReturn;
-(void)raiseStalkLayer;
-(void)lowerStalkLayer;
-(void)raiseSingleStalk:(TimeStalk *)ts;
-(void)lowerSingleStalk:(TimeStalk *)ts;

@end
