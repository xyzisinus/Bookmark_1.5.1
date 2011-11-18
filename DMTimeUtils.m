//
//  DMTimeUtils.m
//  VideoStills
//
//  Created by Barry Ezell on 9/4/11.
//  Copyright (c) 2011 Dockmarket LLC. All rights reserved.
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
