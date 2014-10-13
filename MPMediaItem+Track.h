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
//  MPMediaItem+Track.h
//  Bookmark
//
//  Created by Barry Ezell on 8/2/11.
//
//  Category of MPMediaItem. Added in version 1.5 to reduce 
//  dependence on Track because not all items must be persisted.
//

#import <Foundation/Foundation.h>
#import "Bookmark.h"
#import "Track.h"

@interface MPMediaItem (Track) 

@property (nonatomic, readonly) unsigned long long  persistentId;
@property (nonatomic, readonly) BOOL                isPodcast;
@property (nonatomic, readonly) long                duration;
@property (nonatomic, readonly) float               percentComplete;
@property (nonatomic, readonly) long                lastTime;
@property (nonatomic, readonly) long                maxTime;
@property (nonatomic, readonly) NSString            *title;
@property (nonatomic, readonly) NSString            *albumTitle;
@property (nonatomic, readonly) NSString            *author;
@property (nonatomic, readonly) NSDate              *releaseDate;
@property (nonatomic, readonly) int                 trackNumber;
@property (nonatomic, readonly) BOOL                hasTrack;

- (void)updateAsComplete;
- (void)updateAsNew;
- (Track *)associatedTrack;

@end
