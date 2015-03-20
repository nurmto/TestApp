//
//  FoursquareSearchRequest.h
//  TestApp
//
//  Created by Nurmela, Tomi on 17.3.2015.
//  Copyright (c) 2015 Nurmela, Tomi. All rights reserved.
//

#import "FoursquareBaseRequest.h"

@class BackendConfig;
@class FoursquareSearchRequest;

// For executing venue search request to foursquare server
@interface FoursquareSearchRequest : FoursquareBaseRequest

// Initialization.
// latitude and longitude   - current location
// query                    - text that is used for searching specific venues. nil value is not allowed
- (id)initWithLatitude:(double)latitude longitude:(double)longitude query:(NSString *)query;

// When request is completed successfully, this will return array of FoursquareVenueInformation objects, otherwise returns nil
@property(nonatomic, readonly) NSArray *venueInfos;

@end
