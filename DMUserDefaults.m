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
//  DMUserDefaults.m
//  VideoStills
//
//  Created by Barry Ezell on 9/6/11.
//

#import "DMUserDefaults.h"

SYNTHESIZE_SINGLETON_FOR_CLASS_PROTOTYPE(DMUserDefaults);

@implementation DMUserDefaults

SYNTHESIZE_SINGLETON_FOR_CLASS(DMUserDefaults);

- (NSUserDefaults *)defaults {
    return [NSUserDefaults standardUserDefaults];
}

- (void)initializeDefaults {
    
    if ([self objectForKey:CHIME_VOL] == nil)
        [[self defaults] setObject:[NSNumber numberWithFloat:1.0] forKey:CHIME_VOL]; 
    
    if ([self objectForKey:CLICK_VOL]  == nil)
        [[self defaults] setObject:[NSNumber numberWithFloat:1.0] forKey:CLICK_VOL]; 
    
    if ([self objectForKey:BELL_VOL] == nil)
        [[self defaults] setObject:[NSNumber numberWithFloat:0.8] forKey:BELL_VOL]; 
    
    if ([self objectForKey:CHIME_BUZZ] == nil) 
        [[self defaults] setObject:[NSNumber numberWithInt:0] forKey:CHIME_BUZZ];
    
    if ([self objectForKey:CLICK_BUZZ] == nil)
        [[self defaults] setObject:[NSNumber numberWithInt:0] forKey:CLICK_BUZZ];
    
    if ([self objectForKey:BELL_BUZZ] == nil)
        [[self defaults] setObject:[NSNumber numberWithInt:0] forKey:BELL_BUZZ];
    
    if ([self objectForKey:AUTOPLAY] == nil) 
        [[self defaults] setObject:[NSNumber numberWithInt:1] forKey:AUTOPLAY];
    
    if ([self objectForKey:SHAKE_ACTION] == nil)
        [[self defaults] setObject:[NSNumber numberWithInt:4] forKey:SHAKE_ACTION];
        
    if ([self objectForKey:BOOKMARK_TITLE] == nil)
        [[self defaults] setObject:[NSNumber numberWithInt:0] forKey:BOOKMARK_TITLE];
    
    if ([self objectForKey:CURRENT_CATEGORY] == nil) {
#if defined(PODCASTS_LITE)
        [[self defaults] setObject:[NSNumber numberWithInt:LibraryCategoryPodcasts] forKey:CURRENT_CATEGORY];        
#else
        [[self defaults] setObject:[NSNumber numberWithInt:LibraryCategoryBooks] forKey:CURRENT_CATEGORY];
#endif  
    }
    
    if ([self objectForKey:SORT_ORDER] == nil) 
        [[self defaults] setObject:LibrarySortOrderTitle forKey:SORT_ORDER];
    
    if ([self objectForKey:SLEEP_TIMER_SEC] == nil) 
        [[self defaults] setObject:[NSNumber numberWithInt:(45*60)] forKey:SLEEP_TIMER_SEC];
         
    if ([self objectForKey:SLEEP_TIMER_DEAD_MAN] == nil)
        [[self defaults] setObject:[NSNumber numberWithInt:0] forKey:SLEEP_TIMER_DEAD_MAN];
    
    if ([self objectForKey:QUICK_BKMK_DEFAULT]  == nil) 
        [[self defaults] setObject:[NSNumber numberWithInt:0] forKey:QUICK_BKMK_DEFAULT];
   
    if ([self objectForKey:KEEP_AWAKE_HUD] == nil)
        [[self defaults] setObject:[NSNumber numberWithInt:0] forKey:KEEP_AWAKE_HUD];
    
    if ([self objectForKey:EXPANDED_BOOK_SEARCH] == nil) 
        [[self defaults] setObject:[NSNumber numberWithInt:0] forKey:EXPANDED_BOOK_SEARCH];
}

// Reset all settings to defaults
- (void)resetDefaults {
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary] 
                                                       forName:[[NSBundle mainBundle] bundleIdentifier]];
    [self initializeDefaults];
}

#pragma mark - IFCellModel methods

- (void)setObject:(id)value forKey:(NSString *)key {
    [[self defaults] setObject:value 
                        forKey:key];
    //DLog(@"Setting value %@ for %@",value,key);
    [[self defaults] synchronize];
}

- (id)objectForKey:(NSString *)key {
    return [[self defaults] objectForKey:key];
}


@end
