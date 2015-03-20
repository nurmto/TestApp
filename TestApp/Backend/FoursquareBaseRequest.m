//
//  FoursquareBaseRequest.m
//  TestApp
//
//  Created by Nurmela, Tomi on 18.3.2015.
//  Copyright (c) 2015 Nurmela, Tomi. All rights reserved.
//

#import "FoursquareBaseRequest.h"

@interface FoursquareBaseRequest () <NSURLConnectionDataDelegate> {

    // For notifying about request completion
    RequestCompletedFunction _onComplete;
    RequestFailedFunction _onFail;

    // For executing request to the server
    NSURLConnection *_connection;

    // For storing response information
    NSInteger _responseHTTPStatusCode;
    NSMutableData *_responseData;
}
@end

@implementation FoursquareBaseRequest

#pragma mark -

- (void)sendWithConfig:(BackendConfig *)backendConfig onComplete:(RequestCompletedFunction)onComplete onFail:(RequestFailedFunction)onFail {

    // Check that we are not already executing request
    NSAssert(_onComplete == nil, @"onComplete block already exists");
    NSAssert(_onFail == nil, @"onFail block already exists");

    NSParameterAssert(backendConfig);
    NSParameterAssert(onComplete);
    NSParameterAssert(onFail);

    _onComplete = [onComplete copy];
    _onFail = [onFail copy];

    NSURL *requestURL = [self URLWithConfig:backendConfig];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestURL
                                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                            timeoutInterval:60.0];
    [request setValue:@"iOS_test_app" forHTTPHeaderField:@"User-Agent"];

    // Issue request NSRunLoopCommonModes so that it is handled although user is scrolling UI
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [_connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [_connection start];
}

- (void)cancel {
    [_connection cancel];
    _connection = nil;
    // Reset blocks for avoiding retain cycle
    _onComplete = nil;
    _onFail = nil;
}

- (void)completeWithError:(NSError *)error {

    NSLog(@"Request (%@) completed", self.class);
    if (error) {
        NSLog(@"Error: %@", error);
    }
    _connection = nil;
    if (error) {
        RequestFailedFunction onFail = _onFail;
        _onFail = nil;
        _onComplete = nil;
        onFail(self, error);
    } else {
        RequestCompletedFunction onSuccess = _onComplete;
        _onFail = nil;
        _onComplete = nil;
        onSuccess(self);
    }
}

- (NSURL *)URLWithConfig:(BackendConfig *)backendConfig {
    NSAssert(NO, @"Derived class implementation is missing");
    return nil;
}

- (NSError *)parseResponseWithData:(NSData *)data {
    NSAssert(NO, @"Derived class implementation is missing");
    return nil;
}

- (NSError *)parseFailedResponseWithData:(NSData *)data statusCode:(NSInteger)statusCode {

    NSString *errorDescription = [NSString stringWithFormat:NSLocalizedString(@"ERROR_GENERIC_BACKEND_REQUEST_FAILED", @""), statusCode];
    return [NSError TestAppErrorWithErrorCode:kTestAppBackendErrorGeneric description:errorDescription];
}

#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {

    // Store HTTP status code
    _responseHTTPStatusCode = [(NSHTTPURLResponse *)response statusCode];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

    if (_responseData == nil) {
        // Current communication to server results small response bodies (less than 1MB). Now we can use RAM as a response buffer
        // If we would have bigger sized responses we would need to write data to some temporary file
        _responseData = [[NSMutableData alloc] init];
    }
    [_responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

    NSAssert(_onFail != nil, @"onFail missing in error");
    [self completeWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

    _connection = nil;
    // Parse JSON content in a background thread. We can reset _responseData and handle response in a background thread by using local variable.
    // This way it is guaranteed that response data is not accessed from several threads at the same time
    NSData *responseData = _responseData;
    _responseData = nil;
    NSInteger statusCode = _responseHTTPStatusCode;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSError * error;
        // All 2xx responses are handled as success
        if (statusCode >= 200 && statusCode <= 299) {
            // Returned value is not nil if parsing content failed
            error = [self parseResponseWithData:responseData];
        } else {
            error = [self parseFailedResponseWithData:responseData statusCode:statusCode];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            // It is possible that request was cancelled while we were parsing in a background thread
            // If request has been cancelled then _onComplete block is nil
            if (_onComplete != nil) {
                [self completeWithError:error];
            }
        });
    });
}

@end
