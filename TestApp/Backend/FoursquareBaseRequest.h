//
//  FoursquareBaseRequest.h
//  TestApp
//
//  Created by Nurmela, Tomi on 18.3.2015.
//  Copyright (c) 2015 Nurmela, Tomi. All rights reserved.
//

@class BackendConfig;
@class FoursquareBaseRequest;

// Callback blocks for notifying user about request completion
// request  - request that has been completed successfully
typedef void (^RequestCompletedFunction)(FoursquareBaseRequest *request);
// request  - request that has been failed
// error    - defines failure reason
typedef void (^RequestFailedFunction)(FoursquareBaseRequest *request, NSError *error);

// Common class for sending requests to foursquare server
@interface FoursquareBaseRequest : NSObject

// Trigger request sending. Asynchronous method. Can be cancelled by using cancel -method. If cancelled callback blocks won't be called
// backendConfig    - Configurable data that is needed for communication with backend
// onComplete       - Called, when response for the request has been received without any error
// onFail           - Called when error has ben occurred, including errors receive from the server
- (void)sendWithConfig:(BackendConfig *)backendConfig onComplete:(RequestCompletedFunction)onComplete onFail:(RequestFailedFunction)onFail;

// Cancel sendWithConfig -request
- (void)cancel;

/***************************************/
// NOTE: Methods below are intended only for communicating with derived classes.

// Get request specific full URL
- (NSURL *)URLWithConfig:(BackendConfig *)backendConfig;

// Parse successful response (HTTP code is 2xx)
// Return: Nil if received data is parsed successfully, otherwise return error
- (NSError *)parseResponseWithData:(NSData *)data;

// Parse failed response (HTTP code != 2xx)
// Return: NSError that defines detailed reason for the error
- (NSError *)parseFailedResponseWithData:(NSData *)data statusCode:(NSInteger)statusCode;

@end
