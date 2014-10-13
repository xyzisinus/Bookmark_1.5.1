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
//  MPMediaItemCollection+Work.h
//  Bookmark
//
//  Created by Barry Ezell on 8/2/11.
//
//  Category of MPMediaItemCollection with added static methods
//  for loading audiobook and pocast collections. 
//  
//  Added in version 1.5 to reduce dependence on Work because not all
//  collections must be persisted.
//

#import <Foundation/Foundation.h>
#import "MasterMusicPlayer.h"
#import "Work.h"

@interface MPMediaItemCollection (Work) 

+ (NSArray *)collectionsForCategory:(LibraryCategory)category withSort:(LibrarySortOrder)sortOrder;
+ (NSArray *)audiobookCollections;
+ (NSArray *)podcastCollections;
+ (MPMediaItemCollection *)collectionForItem:(MPMediaItem *)item;

@property (nonatomic, readonly) NSString            *title;
@property (nonatomic, readonly) NSString            *sortTitle;
@property (nonatomic, readonly) BOOL                isPodcast;
@property (nonatomic, readonly) NSString            *author;
@property (nonatomic, readonly) NSString            *sortAuthor;
@property (nonatomic, readonly) NSDate              *mostRecentDate;
@property (nonatomic, readonly) unsigned long long  persistentId;
@property (nonatomic, readonly) float               percentComplete;
@property (nonatomic, readonly) NSDate              *lastListenedTo;
@property (nonatomic, assign)   NSString            *notes;
@property (nonatomic, readonly) int                 count;
@property (nonatomic, readonly) int                 newCount;
@property (nonatomic, readonly) MPMediaItem         *lastItem;
@property (nonatomic, readonly) NSArray             *bookmarks;

- (UIImage *)artworkAtSize:(CGSize)size;

- (void)saveState;

// Use this only when necessary (e.g., creating a Bookmark). 
// Instead default to using above properties.
- (Work *)associatedWork:(BOOL)shouldCreate;
- (Work *)associatedWork;
- (void)updateAsComplete;
- (void)updateAsNew;
- (NSString *)formatForEmail;

@end
