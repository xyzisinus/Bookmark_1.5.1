//
//  SleepTimeEditViewController.m
//  Bookmark
//
//  Created by Barry Ezell on 11/10/11.
//  Copyright (c) 2011 Dockmarket LLC. All rights reserved.
//

#import "SleepTimeEditViewController.h"

@implementation SleepTimeEditViewController

@synthesize picker, parentVC;

- (void)dealloc {
    [picker release]; picker = nil;
    [parentVC release]; parentVC = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];    
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Countdown Time";
        
    UIImageView *imgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dark_leather_2.png"]] autorelease];
    [self.view addSubview:imgView];
    [self.view sendSubviewToBack:imgView]; 
        
    // Add the picker view
    self.picker = [[[UIPickerView alloc] initWithFrame:CGRectMake(10, 70.0, 300.0, 100.0)] autorelease];
    picker.showsSelectionIndicator = YES;
    picker.delegate = self;
    [self.view addSubview:picker];    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self populatePicker];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    parentVC.totalSeconds = [self totalSeconds];
    parentVC.elapsedSeconds = 0;
}

- (void)setTotalSeconds:(int)seconds {
    hours = seconds / 3600;
	seconds -= (hours * 3600);
	minutes = seconds / 60;
}

- (int)totalSeconds {
    return (hours * 3600) + (minutes * 60);
}

- (void)populatePicker {
    [picker selectRow:hours inComponent:0 animated:NO];
    [picker selectRow:minutes inComponent:1 animated:NO];
}

#pragma mark - Picker delegate methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {    
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {         
    switch (component) {
        case 0:
            return 24;
            break;        
        default:
            return 60;
    }
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (row == 0) {
        return [NSString stringWithFormat:@"%i %@",row,(component == 0 ? @"hr" : @"min")];
    } else {
        return [NSString stringWithFormat:@"%i",row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    hours = [pickerView selectedRowInComponent:0];
    minutes = [pickerView selectedRowInComponent:1]; 
}


@end
