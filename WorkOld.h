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
//  Work.h
//  Bookmark
//
//  Created by Barry Ezell on 1/14/10.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class Track;
@class Bookmark;

@protocol WorkDelegate
@required
- (void)worksWereLoaded;
@end

@interface Work :  NSManagedObject {
	int currentTrackIdx;
	BOOL hasSetInitialTrackIdx;
}

@property (nonatomic, retain) NSString* author;
@property (nonatomic, retain) NSString* sortAuthor;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* sortTitle;
@property (nonatomic, retain) NSString* notes;
@property (nonatomic, retain) NSNumber* category;
@property (nonatomic, retain) NSNumber* present;
@property (nonatomic, retain) NSNumber* percentComplete;
@property (nonatomic, retain) NSNumber* tracksCount;
@property (nonatomic, retain) NSSet* tracks;
@property (nonatomic, retain) Track * currentTrack;
@property (nonatomic, readonly) int currentTrackIdx;
@property (nonatomic, retain) NSDate   * lastListenedTo;
@property (nonatomic, retain) MPMediaItemCollection *mediaItemCollection;

+ (void)loadWorksForCategory:(LibraryCategory)category;
+ (Work *)workForTitle:(NSString *)albumTitle 
			 andAuthor:(NSString *)author 
		   andCategory:(LibraryCategory)category 
			 inContext:(NSManagedObjectContext *)context;
+ (Work *)workForMediaItem:(MPMediaItem *)item;
+ (NSString *)titleForSortingFromLongTitle:(NSString *)title;
+ (NSString *)authorForSorting:(NSString *)author;

- (void)save;
- (UIImage *)artworkAtSize:(CGSize)size;
- (int)trackCount;
- (int)newTrackCount;
- (LibraryCategory)categoryRaw;
- (void)setCategoryRaw:(LibraryCategory)category;
- (NSArray *)orderedBookmarks;
- (Track *)currentOrFirstTrack;
- (Track *)incrementCurrentTrack;
- (Track *)decrementCurrentTrack;
- (void)chooseCurrentTrack:(Track *)track;
- (void)setAndSaveCurrentTrack:(Track *)track;
- (void)updateMetadata;
- (void)updateMetadataForTrackWithID:(uint64_t)targetId;
- (void)resetAsNew;
- (void)setAsCompleted;
- (NSString *)formatForEmail;

@end

@interface Work (CoreDataGeneratedAccessors)
- (void)addTracksObject:(Track *)value;
- (void)removeTracksObject:(Track *)value;
- (void)addTracks:(NSSet *)value;
- (void)removeTracks:(NSSet *)value;

@end

