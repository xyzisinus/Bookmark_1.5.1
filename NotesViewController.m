// Copyright Barry Ezell. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//
//  1. Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer in the
//     documentation and/or other materials provided with the distribution.
//  3. Neither the name of the copyright holder nor the names of its contributors
//     may be used to endorse or promote products derived from this software
//     without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  NotesViewController.m
//  AudiobooksPlus
//
//  Created by Barry Ezell on 7/24/09.
//

#define KEYBOARD_VISIBLE_PORTRAIT CGRectMake(0, 45, 320, 230)
#define KEYBOARD_HIDDEN_PORTRAIT CGRectMake(0, 45, 320, 425)
#define KEYBOARD_VISIBLE_LANDSCAPE CGRectMake(0, 35, 480, 120)
#define KEYBOARD_HIDDEN_LANDSCAPE CGRectMake(0, 35, 480, 285)


#import "NotesViewController.h"

@implementation NotesViewController

@synthesize notesDelegate, notes;

- (void)dealloc {
	//NSLog(@"NotesVC dealloc");
	[notes release];
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIBarButtonItem *hideButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"keyboard_25.png"] 
																					   style:UIBarButtonItemStyleBordered 
																					  target:self action:@selector(hideButtonWasPressed)];	
	self.navigationItem.rightBarButtonItem = hideButton;
    [hideButton release];
	
	//listen for the keyboard showing or hiding to adjust UI
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(keyboardWillShow:) 
												 name: UIKeyboardWillShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(keyboardWillHide:) 
												 name: UIKeyboardWillHideNotification object:nil];
	
	[self.navigationItem setTitle:@"Notes"];
	[notesView setEditable:YES];
	[notesView becomeFirstResponder];
	notesView.text = notes;		
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	
	if (notesDelegate) {
		[notesDelegate notesViewReturningWithNotes:notesView.text];
	}	
}

- (void)hideButtonWasPressed {
	[notesView resignFirstResponder];	
}

-(void) keyboardWillShow:(id)sender {	
	keyboardShowing = YES;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	notesView.frame = [self notesViewFrame];
	[UIView commitAnimations];
}

-(void) keyboardWillHide:(id)sender {
	keyboardShowing = NO;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	notesView.frame = [self notesViewFrame];
	[UIView commitAnimations];	
}

 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {	
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	notesView.frame = [self notesViewFrame];
}

- (CGRect)notesViewFrame {
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	if (orientation == UIDeviceOrientationPortrait) {
		return (keyboardShowing? KEYBOARD_VISIBLE_PORTRAIT : KEYBOARD_HIDDEN_PORTRAIT);
	} else {
		return (keyboardShowing? KEYBOARD_VISIBLE_LANDSCAPE : KEYBOARD_HIDDEN_LANDSCAPE);
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


@end
