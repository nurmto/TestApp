//
//  BackendConfig.h
//  TestApp
//
//  Created by Nurmela, Tomi on 17.3.2015.
//  Copyright (c) 2015 Nurmela, Tomi. All rights reserved.
//

#define FOURSQUARE_PROTOCOL_VERSION @"v2"
#define FOURSQUARE_API_VERSION @"20130815"

// Holds data for backend related communication
@interface BackendConfig : NSObject

@property (nonatomic, readonly) NSString *clientID;
@property (nonatomic, readonly) NSString *clientSecret;
@property (nonatomic, readonly) NSString *foursquareURL;

// Initialization method. Non-nil parameters are not allowed
// clientID:        See https://developer.foursquare.com/start/search
// secret:          See https://developer.foursquare.com/start/search
// foursquareURL:   Base URL to the foursquare API e.g. https://api.foursquare.com
- (id)initWithClientID:(NSString *)clientID clientSecret:(NSString *)secret foursquareURL:(NSString *)foursquareURL;

@end
