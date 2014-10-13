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
//  Bookmark.h
//  Bookmark
//
//  Created by Barry Ezell on 1/14/10.
//

#import <CoreData/CoreData.h>
#import "NotesViewController.h"

@class Track;

@interface Bookmark :  NSManagedObject<NotesViewDelegate> {
}

@property (nonatomic, retain) NSNumber  * startTime;
@property (nonatomic, retain) NSString  * title;
@property (nonatomic, retain) NSString  * notes;
@property (nonatomic, retain) NSNumber  * stopTime;
@property (nonatomic, retain) NSString  * kind;
@property (nonatomic, retain) Track     * track;

// Non-persistent attributes
@property (nonatomic, assign) int       itemIdx;

+ (Bookmark *)createBookmarkForStartTime:(long)seconds isQuickBookmark:(BOOL)quick;

- (void)setDefaultTitle:(MPMediaItemCollection *)col;
- (NSString *)formatForEmail;

@end



