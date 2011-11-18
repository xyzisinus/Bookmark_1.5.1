//
//  SleepTimeEditViewController.h
//  Bookmark
//
//  Created by Barry Ezell on 11/10/11.
//  Copyright (c) 2011 Dockmarket LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SleepTimerViewController.h"

@interface SleepTimeEditViewController : UIViewController <UIPickerViewDelegate> {
    int hours;
    int minutes;
}

@property (nonatomic, retain) UIPickerView              *picker;
@property (nonatomic, assign) int                       totalSeconds;
@property (nonatomic, retain) SleepTimerViewController  *parentVC;

- (void)populatePicker;

@end
