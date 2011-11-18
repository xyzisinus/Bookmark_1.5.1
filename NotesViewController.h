//
//  NotesViewController.h
//  AudiobooksPlus
//
//  Created by Barry Ezell on 7/24/09.
//  Copyright 2009 Dockmarket LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

//Since Book and Bookmark both have notes, this abstracts the notes accessors.
//Both models implement this delegate.
@protocol NotesViewDelegate
@required
- (void)notesViewReturningWithNotes:(NSString *)notes;
@end

@interface NotesViewController : UIViewController <UITextViewDelegate> {
	IBOutlet UITextView *notesView;	
	NSString *notes;
	id notesDelegate;
	BOOL keyboardShowing;
}

@property (nonatomic, assign) id<NotesViewDelegate> notesDelegate;
@property (nonatomic, retain) NSString *notes;

- (void)hideButtonWasPressed;
- (void)keyboardWillShow:(id)sender;
- (void)keyboardWillHide:(id)sender;
- (CGRect)notesViewFrame;

@end
