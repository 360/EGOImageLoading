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
#import "ServiceAgent.h"
#import "SugarSyncSession.h"


@implementation EGOImageLoadConnection
@synthesize imageURL=_imageURL, response=_response, delegate=_delegate, timeoutInterval=_timeoutInterval;
@synthesize applyPrieveiewEncoding;

- (id)initWithImageURL:(NSURL*)aURL delegate:(id)delegate {
	if((self = [super init])) {
		_imageURL = [aURL retain];
		self.delegate = delegate;
		_responseData = [[NSMutableData alloc] init];
		self.timeoutInterval = 30;
	}

	return self;
}

- (void)start {
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:self.imageURL
																cachePolicy:NSURLRequestReturnCacheDataElseLoad
															timeoutInterval:self.timeoutInterval];
    NSString *tokenString = AppController.serviceAgent.session.authorizationToken;
    [request setValue:tokenString forHTTPHeaderField:@"Authorization"];
	[request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    switch(applyPrieveiewEncoding) {
        case EgoPreviewEncodingFormat80x80:
            [request setValue:@"image/jpeg; pxmax=80;pymax=80;sq=(0	);r=(0);" forHTTPHeaderField:@"Accept"];
            break;
        case EgoPreviewEncodingFormat80x80Quadratic:
            [request setValue:@"image/jpeg; pxmax=80;pymax=80;sq=(1);r=(0);" forHTTPHeaderField:@"Accept"];
            break;
        case EgoPreviewEncodingFormat500x500:
            [request setValue:@"image/jpeg; pxmax=500;pymax=500;sq=(0);r=(0);" forHTTPHeaderField:@"Accept"];
            break;
        case EgoPreviewEncodingFormat800x800:
            [request setValue:@"image/jpeg; pxmax=800;pymax=800;sq=(0);r=(0);" forHTTPHeaderField:@"Accept"];
            break;
        default:
            break;
    }
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
	self.response = response;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	if(connection != _connection) return;

	if([self.delegate respondsToSelector:@selector(imageLoadConnectionDidFinishLoading:)]) {
		[self.delegate imageLoadConnectionDidFinishLoading:self];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if(connection != _connection) return;

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
