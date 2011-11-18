//
//  TimeRibbonSetting.h
//  Bookmark
//
//  Created by Barry Ezell on 8/22/10.
//  Copyright 2010 Dockmarket LLC. All rights reserved.
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
