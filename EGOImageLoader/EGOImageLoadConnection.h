//
//  EGOImageLoadConnection.h
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

#import <Foundation/Foundation.h>

typedef enum {
    EgoPreviewEncodingFormatNone,
    EgoPreviewEncodingFormat80x80, /// This format is used to get icon 80x80.png
    EgoPreviewEncodingFormat80x80Quadratic, // This fromat is used to get icon for 80x80!.png
    EgoPreviewEncodingFormat500x500,    // This format is used to get photo 500x500.jpg
    EgoPreviewEncodingFormat800x800	// This format is used to get photo in 800x800.jpeg

} EgoPreviewEncodingFormat;


@protocol EGOImageLoadConnectionDelegate;

@interface EGOImageLoadConnection : NSObject {
@private
	NSURL* _imageURL;
	NSURLResponse* _response;
	NSMutableData* _responseData;
	NSURLConnection* _connection;
	NSTimeInterval _timeoutInterval;

	id<EGOImageLoadConnectionDelegate> _delegate;
    EgoPreviewEncodingFormat applyPrieveiewEncoding;
}

- (id)initWithImageURL:(NSURL*)aURL delegate:(id)delegate;

- (void)start;
- (void)cancel;

@property(nonatomic,readonly) NSData* responseData;
@property(nonatomic,readonly,getter=imageURL) NSURL* imageURL;

@property(nonatomic,retain) NSURLResponse* response;
@property(nonatomic,assign) id<EGOImageLoadConnectionDelegate> delegate;

@property(nonatomic,assign) NSTimeInterval timeoutInterval; // Default is 30 seconds
@property(nonatomic,assign) EgoPreviewEncodingFormat applyPrieveiewEncoding;

@end

@protocol EGOImageLoadConnectionDelegate<NSObject>
- (void)imageLoadConnectionDidFinishLoading:(EGOImageLoadConnection *)connection;
- (void)imageLoadConnection:(EGOImageLoadConnection *)connection didFailWithError:(NSError *)error;
@end
