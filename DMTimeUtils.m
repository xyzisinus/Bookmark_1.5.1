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
//  DMTimeUtils.m
//  VideoStills
//
//  Created by Barry Ezell on 9/4/11.
//

#import "DMTimeUtils.h"

@implementation DMTimeUtils

static NSString *separator;

// Returns seconds formatted as HH:MM:SS
// Respects country-specific format (see http://stackoverflow.com/questions/4109587/how-to-localize-a-timer-on-iphone)
+ (NSString *)formatSeconds:(long)seconds accessible:(BOOL)accessible {
    
    if (!separator) {
        NSLocale *curLocale = [NSLocale currentLocale];
        NSArray *dotLocales = [NSArray arrayWithObjects:@"DK",@"FI",@"ME",@"RS",nil];
        separator = ([dotLocales containsObject:[curLocale objectForKey:NSLocaleCountryCode]] ? @"." : @":");         
    }
    
    int hours = seconds / 3600;
	seconds -= (hours * 3600);
	int mins = seconds / 60;
	seconds -= (mins * 60);	
	
    if (hours > 0) {
        if (accessible == NO) 
            return [NSString stringWithFormat:@"%i%@%02d%@%02d", hours, separator, mins, separator, seconds];
        else
            return [NSString stringWithFormat:@"%i hours %02d minutes %02d seconds", hours, mins, seconds];
	} else {
        if (accessible == NO)
            return [NSString stringWithFormat:@"%02d%@%02d", mins, separator, seconds];        
        else
            return [NSString stringWithFormat:@"%02d  minutes %02d seconds", mins, seconds]; 
	}  
}

+ (NSString *)formatSeconds:(long)seconds {
    return [self formatSeconds:seconds accessible:NO];
}

+ (NSDateComponents*)dateComponents:(long)seconds {
        
    int hours = seconds / 3600;
	seconds -= (hours * 3600);
	int mins = seconds / 60;
	seconds -= (mins * 60);	
    
    NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
    [comps setHour:hours];
    [comps setMinute:mins];
    [comps setSecond:seconds];
    
    return comps;
}

+ (long)secondsForDateComponents:(NSDateComponents *)comps {
    return comps.second + (comps.minute * 60) + (comps.hour * 360);
}

@end
