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
//  BookmarkViewController.h
//  Bookmark
//
//  Created by Barry Ezell on 10/5/11.
//

#import <UIKit/UIKit.h>
#import "Bookmark.h"
#import "NotesViewController.h"
#import "TimeEditTableViewController.h"
#import "EditableTableViewCell.h"
#import "EditableTableViewCellDelegate.h"

@interface BookmarkViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, EditableTableViewCellDelegate, NotesViewDelegate, UIActionSheetDelegate> {
    EditableTableViewCell       *editingTableViewCell;
    BOOL                        willReturnFromTimeEdit;
    BOOL                        isPlaying;
}

@property (nonatomic, retain) IBOutlet UITableView      *tableView;
@property (nonatomic, retain) IBOutlet UIToolbar        *toolbar;
@property (nonatomic, retain) Bookmark                  *bookmark;
@property (nonatomic, retain) NSIndexPath               *curIdxPath;
@property (nonatomic, retain) UIView                    *notesHeaderView;
@property (nonatomic, assign) BOOL                      isNew;

- (IBAction)playStopButtonWasPressed:(id)sender;
- (IBAction)actionButtonWasPressed:(id)sender;
- (IBAction)trashButtonWasPressed:(id)sender;
- (void)updateToolbar;
- (void)deleteBookmark;
- (void)shareViaNativeTwitter:(NSString *)text;
- (BOOL)reachable:(NSString *)hostName;

@end
