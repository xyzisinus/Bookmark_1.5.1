//
//  TimeEditTableViewController.h
//  Bookmark
//
//  Created by Barry Ezell on 10/10/11.
//  Copyright (c) 2011 Dockmarket LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bookmark.h"

@interface TimeEditTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {    
    BOOL isPlaying;
    int hours;
    int minutes;
    int seconds;
    long duration;
}

@property (nonatomic, retain) IBOutlet UITableView      *tableView;
@property (nonatomic, retain) IBOutlet UIToolbar        *toolbar;
@property (nonatomic, retain) Bookmark                  *bookmark;
@property (nonatomic, retain) UIPickerView              *picker;

- (IBAction)playStopButtonWasPressed:(id)sender;
- (void)updateToolbar;
- (void)populatePicker:(BOOL)animated;

@end
