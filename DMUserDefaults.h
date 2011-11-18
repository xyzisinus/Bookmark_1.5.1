//
//  DMUserDefaults.h
//  VideoStills
//
//  Created by Barry Ezell on 9/6/11.
//  Copyright (c) 2011 Dockmarket LLC. All rights reserved.
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
