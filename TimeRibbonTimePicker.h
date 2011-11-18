//
//  TimeRibbonTimePicker.h
//  Bookmark
//
//  Created by Barry Ezell on 8/22/10.
//  Copyright 2010 Dockmarket LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeRibbonSettingsViewController.h"
#import "TimeRibbonSetting.h"

@interface TimeRibbonTimePicker : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
	
}

@property (nonatomic, retain) IBOutlet UIPickerView *picker;
@property (nonatomic, retain) TimeRibbonSetting *curSetting;
@property (nonatomic, retain) TimeRibbonSettingsViewController *parentController;

@end
