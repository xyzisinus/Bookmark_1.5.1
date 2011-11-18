//
//  TimeRibbonSettingsViewController.h
//  Bookmark
//
//  Created by Barry Ezell on 8/20/10.
//  Copyright 2010 Dockmarket LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeRibbonView.h"
#import "TimeRibbonSetting.h"

@interface TimeRibbonSettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> 

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) TimeRibbonView *timeRibbon;
@property (nonatomic, retain) NSArray *trSettings;

- (void)updateSettings;
- (IBAction)restoreDefaultsButtonWasPressed;

@end
