//
//  LogViewController.m
//  Bookmark
//
//  Created by Barry Ezell on 3/29/10.
//  Copyright 2010 Dockmarket LLC. All rights reserved.
//

#import "LogViewController.h"


@implementation LogViewController


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSString *curVer = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	NSString *docsDirPath = [NSHomeDirectory() stringByAppendingPathComponent: @"Documents"];
	NSString *logPath = [NSString stringWithFormat:@"%@/upgrade_%@.txt",docsDirPath,curVer];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:logPath];
	
	if (fileExists) {
		textView.text = [NSString stringWithContentsOfFile:logPath encoding:NSUTF8StringEncoding error:nil];		
	} else {
		textView.text = @"No upgrade log found.";
	}	
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
