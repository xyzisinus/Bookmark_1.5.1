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
//  TimeRibbonSetting.h
//  Bookmark
//
//  Created by Barry Ezell on 8/22/10.
//

#import <Foundation/Foundation.h>


@interface TimeRibbonSetting : NSObject {
	int seconds;
	NSString *description;
}

@property (nonatomic, assign) int seconds;
@property (nonatomic, assign) int minutes;
@property (nonatomic, assign) int hours;
@property (nonatomic, retain) NSString *description;

+ (NSArray *)settings;
+ (NSArray *)persistArray:(NSArray *)arr;

- (id)initSettingNumber:(int)nr;
- (void)persistForSettingNumber:(int)nr;
- (int)seconds:(BOOL)positive;
- (NSString *)description:(BOOL)positive;
- (NSString *)longDescription;
- (NSString *)timeScale;
- (void)setMinutes:(int)minutes;
- (void)setHours:(int)hours;

@end
