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
//  AdViewController.m
//  Bookmark
//
//  Created by Barry Ezell on 4/22/10.
//

#import "AdBannerViewController.h"

#define HOST @"http://ads.dockmarket.net"

#ifdef DEBUG
#define LOAD_DELAY 2
#else
#define LOAD_DELAY 5
#endif

#define BOOKMARK_ITUNES_URL @"http://click.linksynergy.com/fs-bin/stat?id=eXyB0R5Jlew&offerid=146261&type=3&subid=0&tmpid=1826&RD_PARM1=http%253A%252F%252Fitunes.apple.com%252Fus%252Fapp%252Fbookmark%252Fid326290323%253Fmt%253D8%2526uo%253D6%2526partnerId%253D30"

@implementation AdBannerViewController

@synthesize fullUrl, iTunesUrl, bannerImage;

- (void)dealloc {
	[fullUrl release];
	[iTunesUrl release];
	[bannerImage release];
    [super dealloc];
}

//Load existing ad or default
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//load default as Bookmark
	imageView.image = [UIImage imageNamed:@"ad_bkmk_upgrade.png"];
	self.fullUrl = [NSURL URLWithString:BOOKMARK_ITUNES_URL];
	
	//attempt to load another ad after a delay
	//[self performSelector:@selector(fetchNewAd) withObject:nil afterDelay:LOAD_DELAY];
}

- (void)fetchNewAd {	
	
    /*
	//optionally add last played title
	NSString *lastPlayed = nil;
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	if ([prefs valueForKey:@"lastPlayedTrack"]) {
		lastPlayed = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
																		  (CFStringRef)[prefs valueForKey:@"lastPlayedTrack"], 
																		  NULL, 
																		  CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8);
	}
	
	NSString *udid = [UIDevice currentDevice].uniqueIdentifier;
	NSString *urlString = [[NSString alloc] initWithFormat:@"%@/banners/fetch.json?u=%@&l=%@",HOST,udid,lastPlayed];
	NSURL *url = [NSURL URLWithString:urlString];
	//NSLog(@"using url: %@",urlString);
	[urlString release];
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setDelegate:self];
	[request startAsynchronous];	
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSString *responseString = [request responseString];
	//NSLog(@"%@",responseString);
	
	@try {		
		NSData *jsonData = [responseString dataUsingEncoding:NSUTF32BigEndianStringEncoding];
		NSError *error = nil;
		NSDictionary *dict = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
		NSDictionary *innerDict = [dict objectForKey:@"banner"];
		self.fullUrl = [NSURL URLWithString:[innerDict objectForKey:@"full_url"]];
		
		//load banner image
		NSString *imgUrlString = [[NSString alloc] initWithFormat:@"%@/%@",HOST,[innerDict objectForKey:@"image_url"]];
		NSURL *imgUrl = [NSURL URLWithString:imgUrlString];
		[imgUrlString release];
		NSData *data = [NSData dataWithContentsOfURL:imgUrl];
		self.bannerImage = [UIImage imageWithData:data];
		[self beginSwapInNewBanner];
	}
	@catch (NSException * e) {
		NSLog(@"JSON parse failed for ad request. Response string: %@", responseString);
	}
	@finally {
	}
     */
}

/*
- (void)requestFailed:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	NSLog(@"request failure: %@",[error localizedDescription]);
}
 */

- (void)beginSwapInNewBanner {
	//first fade out existing banner
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1.0];
	imageView.alpha = 0.0;
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(completeSwapInNewBanner)];
	[UIView commitAnimations];
}

- (void)completeSwapInNewBanner {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	imageView.image = self.bannerImage;
	imageView.alpha = 1.0;
	[UIView commitAnimations];
}


#pragma mark -
#pragma mark Touch methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[spinner startAnimating];
	[self performSelectorInBackground:@selector(recordClick:) withObject:self.fullUrl];
	[self openReferralURL:self.fullUrl];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

#pragma mark -
#pragma mark Link referral methods

//POST to /clicks on ad server
- (void)recordClick:(NSURL *)referralURL {
    /*
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];							  
	
	NSString *udid = [UIDevice currentDevice].uniqueIdentifier;
	NSString *urlString = [[NSString alloc] initWithFormat:@"%@/clicks",HOST];
	NSURL *url = [NSURL URLWithString:urlString];
	//NSLog(@"using url: %@",urlString);
	[urlString release];

	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setPostValue:udid forKey:@"u"];
	[request setPostValue:referralURL forKey:@"full_url"];
	[request startSynchronous];
							   
	[pool release];
     */
}

//Note: this code is directly from Apple and allows the redirects to happen silently
//until it's time to exit out to iTunes or the App Store.
//See http://developer.apple.com/iphone/library/qa/qa2008/qa1629.html
// Process a LinkShare/TradeDoubler/DGM URL to something iPhone can handle
- (void)openReferralURL:(NSURL *)referralURL {
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:referralURL] delegate:self startImmediately:YES];
    [conn release];
}

// Save the most recent URL in case multiple redirects occur
// "iTunesURL" is an NSURL property in your class declaration
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    self.iTunesUrl = [response URL];
    return request;
}

// No more redirects; use the last URL saved
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[UIApplication sharedApplication] openURL:self.iTunesUrl];
}


#pragma mark -
#pragma mark Cleanup

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



@end
