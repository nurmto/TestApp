//
//  FoursquareSearchRequest.m
//  TestApp
//
//  Created by Nurmela, Tomi on 17.3.2015.
//  Copyright (c) 2015 Nurmela, Tomi. All rights reserved.
//

#import "FoursquareSearchRequest.h"

#import "BackendConfig.h"
#import "FoursquareVenueInformation.h"
#import "NSString+TestApp.h"

@interface FoursquareSearchRequest () <NSURLConnectionDataDelegate> {

    // For request parameters
    double _latitude;
    double _longitude;
    NSString *_query;

    // for holding response data (FoursquareVenueInformation objects)
    NSArray *_venueInfos;
}

@end

@implementation FoursquareSearchRequest

- (id)initWithLatitude:(double)latitude longitude:(double)longitude  query:(NSString *)query {
    self = [super init];
    if (self) {
        _latitude = latitude;
        _longitude = longitude;
        NSParameterAssert(query);
        _query = query;
    }
    return self;
}

#pragma mark request execution


- (NSURL *)URLWithConfig:(BackendConfig *)config {

    // Example request should be:
    // https://api.foursquare.com/v2/venues/search?client_id=<id>&client_secret=secret&v=<api_version>&ll=<latitude,longitude>&query=<query_text>

    NSString *URLString = [NSString stringWithFormat:@"%@/%@/venues/search?client_id=%@&client_secret=%@&v=%@&ll=%f,%f&query=%@",
                           config.foursquareURL, FOURSQUARE_PROTOCOL_VERSION, [config.clientID stringAsURLEncoded],
                           [config.clientSecret stringAsURLEncoded], FOURSQUARE_API_VERSION, _latitude, _longitude,
                           [_query stringAsURLEncoded]];
    return [NSURL URLWithString:URLString];
}



#pragma mark response parsing

- (NSError *)parseResponseWithData:(NSData *)data {

    NSError* error = nil;
    if (data) {
        id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error == nil) {
            error = [self parseJSONObject:jsonObject];
        }
    } else {
        // Response without body. This case was not mentioned in foursquare documentation (is it error or not?). So now we assume that
        // request is completed with success, but no results were found.
        _venueInfos = NSArray.new;
    }
    return error;
}

- (NSError *)parseJSONObject:(id)JSONObject {

    if (JSONObject) {
        // Commented code, because it caused too much logging.
        // NSLog(@"%@", JSONObject);
        id venues = [[JSONObject objectForKey:@"response"] objectForKey:@"venues"];
        if (venues) {
            NSMutableArray *venueInfoArray = [[NSMutableArray alloc] init];
            for (id venue in venues) {
                id location = [venue objectForKey:@"location"];
                id distance = [location objectForKey:@"distance"];
                NSInteger distanceValue = (distance ? [distance integerValue] : kUnknownDistance);
                FoursquareVenueInformation *venueInfo = [[FoursquareVenueInformation alloc] initWithName:[venue objectForKey:@"name"]
                                                                                                 address:[location objectForKey:@"address"]
                                                                                        formattedAddress:[location objectForKey:@"formattedAddress"]
                                                                                                distance:distanceValue];
                [venueInfoArray addObject:venueInfo];
            }
            // Create immutable array for receiver
            _venueInfos = [NSArray arrayWithArray:venueInfoArray];
        }
    }
    return nil;
}

@end
