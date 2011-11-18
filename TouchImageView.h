//
//  TouchImageView.h
//  AudiobooksPlus
//
//  Created by Barry Ezell on 7/23/09.
//  Copyright 2009 Dockmarket LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	DetectedSwipeModeUp,
	DetectedSwipeModeDown,
	DetectedSwipeModeLeft,
	DetectedSwipeModeRight,
} DetectedSwipeMode;

@protocol TouchImageViewDelegate <NSObject>
@required
- (void)imageWasTouched;
@optional
- (void)swipeDetectedForMode:(DetectedSwipeMode)mode;
@end


@interface TouchImageView : UIImageView <UIAccelerometerDelegate> {
	id delegate;	
	CGPoint startTouchPt;
}

@property (nonatomic, assign) id<TouchImageViewDelegate> delegate;

- (void)notifySwipeDetected:(DetectedSwipeMode)mode;

@end
