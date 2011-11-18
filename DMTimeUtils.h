//
//  DMTimeUtils.h
//  VideoStills
//
//  Created by Barry Ezell on 9/4/11.
//  Copyright (c) 2011 Dockmarket LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMTimeUtils : NSObject

+ (NSString *)formatSeconds:(long)s;
+ (NSString *)formatSeconds:(long)s accessible:(BOOL)accessible;
+ (NSDateComponents*)dateComponents:(long)s;
+ (long)secondsForDateComponents:(NSDateComponents *)comps;

@end
