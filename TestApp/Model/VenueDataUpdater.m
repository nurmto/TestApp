//
//  VenueDataUpdater.m
//  TestApp
//
//  Created by Nurmela, Tomi on 17.3.2015.
//  Copyright (c) 2015 Nurmela, Tomi. All rights reserved.
//

#import "VenueDataUpdater.h"

#import "BackendConfig.h"
#import "FoursquareSearchRequest.h"
#import "FoursquareVenueInformation.h"
#import "LocationManager.h"

// Definitions that are needed for communicating with foursquare backend
#define FOURSQUARE_CLIENT_ID @"CYEMKOM4OLTP5PHMOFVUJJAMWT5CH5G1JBCYREATW21XLLSZ"
#define FOURSQUARE_CLIENT_SECRET @"GYNP4URASNYRNRGXR5UEN2TGTKJHXY5FGSAXTIHXEUG1GYM2"
#define FOURSQUARE_HOST @"https://api.foursquare.com"

@interface VenueDataUpdater () {

    BackendConfig *_config;
    // For executing search request
    FoursquareSearchRequest *_searchRequest;

    // For notifying search result
    VenueSearchFunction _onComplete;
    VenueSearchFailedFunction _onFail;
}
@end

@implementation VenueDataUpdater

- (id)init {

    self = [super init];
    if (self) {
        _config = [[BackendConfig alloc] initWithClientID:FOURSQUARE_CLIENT_ID
                                             clientSecret:FOURSQUARE_CLIENT_SECRET
                                            foursquareURL:FOURSQUARE_HOST];
    }
    return self;
}

- (void)searchVenuesWithQuery:(NSString *)query
                   onComplete:(VenueSearchFunction)onComplete
                       onFail:(VenueSearchFailedFunction)onFail {

    NSParameterAssert(query);
    NSParameterAssert(onComplete);
    NSParameterAssert(onFail);

    // Caller should take care of cancelling before initiating a new search
    NSAssert(_searchRequest == nil, @"Previous request already ongoing");
    NSAssert(_onComplete == nil, @"Previous search already ongoing");
    NSAssert(_onFail == nil, @"Previous search already ongoing 2");

    _onComplete = [onComplete copy];
    _onFail = [onFail copy];
    // First get current location.
    [[LocationManager sharedLocationManager] currentLocationWithObserver:self
                                                              onComplete:^(double latitude, double longitude) {
                                                                  [self sendSearchRequestWithQuery:query latitude:latitude longitude:longitude];
                                                              } onFailed:^(NSError *error) {
                                                                  [self failWithError:error];
                                                              }];
}

- (void)cancel {
    [[LocationManager sharedLocationManager] cancelWithObserver:self];
    [_searchRequest cancel];
    _searchRequest = nil;
    _onComplete = nil;
    _onFail = nil;
}

- (void) sendSearchRequestWithQuery:(NSString *)query latitude:(double)latitude longitude:(double)longitude {

    // Initialize search request and send it
    _searchRequest = [[FoursquareSearchRequest alloc] initWithLatitude:latitude longitude:longitude query:query];
    [_searchRequest sendWithConfig:_config onComplete:^(FoursquareBaseRequest *request) {
        NSArray *venueInfos = ((FoursquareSearchRequest *)request).venueInfos;
        _searchRequest = nil;
        [self venueDataReceived:venueInfos];

    } onFail:^(FoursquareBaseRequest *request, NSError *error) {
        _searchRequest = nil;
        [self failWithError:error];
    }];
}

- (void)venueDataReceived:(NSArray *)venueData {
    // Sort venues, nearest first
    NSArray *sortedArray = [venueData sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSInteger obj1Distance = ((FoursquareVenueInformation *)obj1).distance;
        NSInteger obj2Distance = ((FoursquareVenueInformation *)obj2).distance;
        if ( obj1Distance< obj2Distance) {
            return (NSComparisonResult)NSOrderedAscending;
        } else if (obj1Distance == obj2Distance) {
            return (NSComparisonResult)NSOrderedSame;
        }
        return (NSComparisonResult)NSOrderedDescending;
    }];
    _onFail = nil;
    VenueSearchFunction onComplete = _onComplete;
    _onComplete = nil;
    NSAssert(onComplete != nil, @"Success block missing in completion");
    onComplete(sortedArray);
}

- (void)failWithError:(NSError *)error {
    _onComplete = nil;
    VenueSearchFailedFunction onFail = _onFail;
    NSAssert(onFail != nil, @"Failure block missing in completion");
    onFail(error);
}

@end
