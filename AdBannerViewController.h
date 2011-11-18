//
//  AdViewController.h
//  Bookmark
//
//  Created by Barry Ezell on 4/22/10.
//  Copyright 2010 Dockmarket LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 Protocol for possible future "full-page preview" on select ads
@protocol AdBannerViewControllerDelegate
@required
- (void)displayFullAdForURL:(NSURL *)url;
@end
 */

@interface AdBannerViewController : UIViewController {
	IBOutlet UIImageView *imageView;
	IBOutlet UIActivityIndicatorView *spinner;
	
	NSURL *fullUrl;
	NSURL *iTunesUrl;
	NSTimer *fetchAdTimer;
	UIImage *bannerImage;
}

@property (nonatomic, retain) NSURL *fullUrl;
@property (nonatomic, retain) NSURL *iTunesUrl;
@property (nonatomic, retain) UIImage *bannerImage;

- (void)fetchNewAd;
- (void)recordClick:(NSURL *)referralURL;
- (void)openReferralURL:(NSURL *)referralURL;
- (void)beginSwapInNewBanner;
- (void)completeSwapInNewBanner;

@end
