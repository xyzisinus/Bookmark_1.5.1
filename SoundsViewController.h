//
//  SoundsViewController.h
//  Bookmark
//
//  Created by Barry Ezell on 11/8/11.
//  Copyright (c) 2011 Dockmarket LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SoundsViewController : UITableViewController {
    UISwitch *switches[3];
    UISlider *sliders[3];
}

- (void)updateDefaults;

@end
