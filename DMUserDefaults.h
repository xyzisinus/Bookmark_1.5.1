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
//  DMUserDefaults.h
//  VideoStills
//
//  Created by Barry Ezell on 9/6/11.
//
//  Singleton pattern via https://github.com/cjhanson/Objective-C-Optimized-Singleton

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "IFCellModel.h"

#define CHIME_VOL                   @"chimeVolume"
#define CHIME_BUZZ                  @"chimeBuzz"
#define CLICK_VOL                   @"clickVol"
#define CLICK_BUZZ                  @"clickBuzz"
#define BELL_VOL                    @"bellVol"
#define BELL_BUZZ                   @"bellBuzz"
#define AUTOPLAY                    @"autoplay"
#define SHAKE_ACTION                @"shakeAction"
#define BOOKMARK_TITLE              @"bookmarkTitleOption"
#define CURRENT_CATEGORY            @"currentCategory"
#define SORT_ORDER                  @"currentSortOrder"
#define SLEEP_TIMER_SEC             @"sleepTimerSeconds"
#define SLEEP_TIMER_DEAD_MAN        @"sleepTimerDeadManSwitch"
#define QUICK_BKMK_DEFAULT          @"isQuickBookmarkDefault"
#define KEEP_AWAKE_HUD              @"keepAwakeInHUD"
#define EXPANDED_BOOK_SEARCH        @"expandedBookSearch"

@interface DMUserDefaults : NSObject <IFCellModel>

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(DMUserDefaults);

- (NSUserDefaults *)defaults;

- (void)initializeDefaults;
- (void)resetDefaults;

@end
