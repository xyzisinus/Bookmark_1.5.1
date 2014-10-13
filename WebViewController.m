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
//  WebViewController.m
//  AudiobooksPlus
//
//  Created by Barry Ezell on 7/29/09.
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
