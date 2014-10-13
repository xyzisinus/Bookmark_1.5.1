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
//  TimeRibbonSetting.m
//  Bookmark
//
//  Created by Barry Ezell on 8/22/10.
//

#import "TimeRibbonSetting.h"


@implementation TimeRibbonSetting

@synthesize seconds, description;

- (void)dealloc {
	[description release];
	[super dealloc];
}

#pragma mark -
#pragma mark Static methods

//create if necessary and return an array of TimeRibbonSetting objects
//persisted to user defaults
+ (NSArray *)settings {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSArray *arr;
	
	TimeRibbonSetting *s0;
	TimeRibbonSetting *s1;
	TimeRibbonSetting *s2;
	TimeRibbonSetting *s3;
	TimeRibbonSetting *s4;	
	
	if (![prefs valueForKey:@"trs_0_desc"]) {	
		s0 = [[TimeRibbonSetting alloc] init];
		s0.seconds = 30;
		[s0 persistForSettingNumber:0];
		
		s1 = [[TimeRibbonSetting alloc] init];
		s1.seconds = 60;
		[s1 persistForSettingNumber:1];
		
		s2 = [[TimeRibbonSetting alloc] init];
		s2.minutes = 5;
		[s2 persistForSettingNumber:2];
		
		s3 = [[TimeRibbonSetting alloc] init];
		s3.minutes = 15;
		[s3 persistForSettingNumber:3];
		
		s4 = [[TimeRibbonSetting alloc] init];
		s4.minutes = 30;	
		[s4 persistForSettingNumber:4];
		
	} else {
		s0 = [[TimeRibbonSetting alloc] initSettingNumber:0];
		s1 = [[TimeRibbonSetting alloc] initSettingNumber:1];
		s2 = [[TimeRibbonSetting alloc] initSettingNumber:2];
		s3 = [[TimeRibbonSetting alloc] initSettingNumber:3];
		s4 = [[TimeRibbonSetting alloc] initSettingNumber:4];
	}
	
	arr = [NSArray arrayWithObjects:s0, s1, s2, s3, s4, nil];
	[s0 release];
	[s1 release];
	[s2 release];
	[s3 release];
	[s4 release];

	return arr;
}

//sort array by seconds, persist each object, and return sorted array
+ (NSArray *)persistArray:(NSArray *)arr {
	
	NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"seconds" ascending:YES];
	NSArray *sortedArr = [arr sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sort,nil]];
	[sort release];
	
	int idx = 0;
	for (TimeRibbonSetting *trs in sortedArr) {
		[trs persistForSettingNumber:idx];
		idx++;
	}
	
	return sortedArr;
}

#pragma mark -
#pragma mark Constructors and Persistence methods

//init and load from prefs setting number (0-4)
- (id)initSettingNumber:(int)nr {
	if (self = [super init]) {
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		self.seconds = [prefs integerForKey:[NSString stringWithFormat:@"trs_%i_sec",nr]];
		self.description = [prefs valueForKey:[NSString stringWithFormat:@"trs_%i_desc",nr]];
	}
	
	return self;
}

- (void)persistForSettingNumber:(int)nr {	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setValue:self.description forKey:[NSString stringWithFormat:@"trs_%i_desc",nr]];
	[prefs setInteger:self.seconds forKey:[NSString stringWithFormat:@"trs_%i_sec",nr]];
	[prefs synchronize];	
}

#pragma mark -
#pragma mark Getters

//return the seconds defined by this setting in either a negative or positive value
- (int)seconds:(BOOL)positive {
	return (positive ? self.seconds : self.seconds * -1);
}

//return the description of this setting in either a negative or positive value
- (NSString *)description:(BOOL)positive {
	if (positive) {
		return [NSString stringWithFormat:@"+%@",self.description];
	} else {
		return [NSString stringWithFormat:@"-%@",self.description];
	}
}

//e.g., "30 seconds" instead of "+30s"
- (NSString *)longDescription {
	NSString *str = [self description:YES];
	str = [str stringByReplacingOccurrencesOfString:@"+" withString:@""];
	
	NSString *scale = [self timeScale];
	if (scale == @"Seconds") {
		return [str stringByReplacingOccurrencesOfString:@"s" withString:@" seconds"];
	} else if (scale == @"Minutes") {
		return [str stringByReplacingOccurrencesOfString:@"m" withString:@" minutes"];
	} else {
		return [str stringByReplacingOccurrencesOfString:@"h" withString:@" hours"];
	}
}

//either "Seconds", "Minutes", or "Hours"
- (NSString *)timeScale {
	if ([self.description rangeOfString:@"s"].length > 0) {
		return @"Seconds";
	} else if ([self.description rangeOfString:@"m"].length > 0) {
		return @"Minutes";
	} else {
		return @"Hours";
	}
}

- (int)minutes {
	return seconds / 60;
}

- (int)hours {
	return seconds / 60 / 60;
}

#pragma mark -
#pragma mark Setters

- (void)setSeconds:(int)s {
	seconds = s;
	self.description = [NSString stringWithFormat:@"%is",s];
} 

- (void)setMinutes:(int)minutes {
	seconds = minutes * 60;
	self.description = [NSString stringWithFormat:@"%im",minutes];
}

- (void)setHours:(int)hours {
	seconds = hours * 60 * 60;
	self.description = [NSString stringWithFormat:@"%ih",hours];
}

@end
