//
//  EGOImageLoadConnection.m
//  EGOImageLoading
//
//  Created by Shaun Harrison on 12/1/09.
//  Copyright (c) 2009-2010 enormego
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "EGOImageLoadConnection.h"
#import "ApplicationController.h"
#import "NetworkIndicatorManager.h"
#import "ServiceAgent.h"
#import "SugarSyncSession.h"
#import "SugarSyncUrl.h"

@implementation EGOImageLoadConnection
@synthesize imageURL=_imageURL, response=_response, delegate=_delegate, timeoutInterval=_timeoutInterval;

- (id)initWithImageURL:(NSURL*)aURL delegate:(id)delegate {
	if((self = [super init])) {
		_imageURL = [aURL retain];
		self.delegate = delegate;
		_responseData = [[NSMutableData alloc] init];
		self.timeoutInterval = 60;
	}

	return self;
}

- (void)start {
    // to take into account transcoding the client appends an transcoding identifier to the end of the URL. self.imageURL
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:self.imageURL
																cachePolicy:NSURLRequestReturnCacheDataElseLoad
															timeoutInterval:self.timeoutInterval];
    NSString *tokenString = AppController.serviceAgent.session.authorizationToken;
    [request setValue:tokenString forHTTPHeaderField:@"Authorization"];
	[request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    if([self.imageURL isKindOfClass:[SugarSyncURL class]]) {
        switch(((SugarSyncURL*)self.imageURL).transcoding) {
            case EgoPreviewEncodingFormat80x80:
                [request setValue:@"image/jpeg; pxmax=80;pymax=80;sq=(0	);r=(0);" forHTTPHeaderField:@"Accept"];
                NSLog(@"Download res 80x80");
                break;
            case EgoPreviewEncodingFormat80x80Quadratic:
                NSLog(@"Download res 80x80 square");
                [request setValue:@"image/jpeg; pxmax=80;pymax=80;sq=(1);r=(0);" forHTTPHeaderField:@"Accept"];
                break;
            case EgoPreviewEncodingFormat500x500:
                NSLog(@"Download res 500x500");
                [request setValue:@"image/jpeg; pxmax=500;pymax=500;sq=(0);r=(0);" forHTTPHeaderField:@"Accept"];
                break;
            case EgoPreviewEncodingFormat800x800:
                NSLog(@"Download res 800x800");
                [request setValue:@"image/jpeg; pxmax=800;pymax=800;sq=(0);r=(0);" forHTTPHeaderField:@"Accept"];
                break;
            default:
                break;
        }
        NSLog(@"Loading SugarSyncUrl for image url: %@", self.imageURL);
    }
	[[NetworkIndicatorManager sharedNetworkIndicatorManager] increaseNetworkCounter];
	_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	[request release];
}

- (void)cancel {
	[_connection cancel];
}

- (NSData*)responseData {
	return _responseData;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	if(connection != _connection) return;
	[_responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	if(connection != _connection) return;
    NSLog(@"connection didReceiveResponse: %@", response);
	self.response = response;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if(connection != _connection) return;
    NSLog(@"connectionDidFinishLoading: %@", connection);

	if([self.delegate respondsToSelector:@selector(imageLoadConnectionDidFinishLoading:)]) {
        [[NetworkIndicatorManager sharedNetworkIndicatorManager] decreaseNetworkCounter];
		[self.delegate imageLoadConnectionDidFinishLoading:self];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if(connection != _connection) return;

    NSLog(@"NSURLConnection didFailWithError: %@", error);

    [[NetworkIndicatorManager sharedNetworkIndicatorManager] decreaseNetworkCounter];

	if([self.delegate respondsToSelector:@selector(imageLoadConnection:didFailWithError:)]) {
		[self.delegate imageLoadConnection:self didFailWithError:error];
	}
}


- (void)dealloc {
	self.response = nil;
	self.delegate = nil;
	[_connection release];
	[_imageURL release];
	[_responseData release], _responseData = nil;
	[super dealloc];
}

@end
