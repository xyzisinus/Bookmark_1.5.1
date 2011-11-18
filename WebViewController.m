//
//  WebViewController.m
//  AudiobooksPlus
//
//  Created by Barry Ezell on 7/29/09.
//  Copyright 2009 Dockmarket LLC. All rights reserved.
//

#import "WebViewController.h"


@implementation WebViewController

@synthesize fileName, url;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (url) {
		[webView loadRequest:[NSURLRequest requestWithURL:url]];
	} else if (fileName) {
		NSString *file = [[NSBundle mainBundle] pathForResource:fileName ofType:@"html"];
		NSString *html = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];		
		[webView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
	}	
}

#pragma mark UIWebViewDelegate methods

//load addresses within bookmarkapp.com in same window, else exit app and open safari
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	
	//load in the app if the link wasn't clicked (e.g., iTunes RSS feed)
	if (navigationType != UIWebViewNavigationTypeLinkClicked) return YES;
	
	NSString *reqStr = [[request URL] absoluteString];
	if ([reqStr length] >= 22) {
		if ([[reqStr substringToIndex:22] isEqualToString:@"http://bookmarkapp.com"]) {			
			return YES;
		}
	}
		
	[[UIApplication sharedApplication] openURL:request.URL];
	return NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[spinny startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[spinny stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[spinny stopAnimating];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[fileName release];
	[url release];
    [super dealloc];
}


@end
