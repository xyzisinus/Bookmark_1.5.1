//
//  WebViewController.h
//  AudiobooksPlus
//
//  Created by Barry Ezell on 7/29/09.
//  Copyright 2009 Dockmarket LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView *webView;
	IBOutlet UIActivityIndicatorView *spinny;
	
	NSURL *url;
	NSString *fileName;
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSString *fileName;


@end
