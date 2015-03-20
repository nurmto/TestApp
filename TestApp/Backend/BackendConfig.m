//
//  BackendConfig.m
//  TestApp
//
//  Created by Nurmela, Tomi on 17.3.2015.
//  Copyright (c) 2015 Nurmela, Tomi. All rights reserved.
//

#import "BackendConfig.h"

@interface BackendConfig () {
    NSString *_clientID;
    NSString *_clientSecret;
    NSString *_foursquareURL;
}
@end

@implementation BackendConfig

- (id)initWithClientID:(NSString *)clientID clientSecret:(NSString *)secret foursquareURL:(NSString *)foursquareURL {
    self = [super init];
    if (self) {
        NSParameterAssert(clientID);
        NSParameterAssert(secret);
        NSParameterAssert(foursquareURL);
        _clientID = clientID;
        _clientSecret = secret;
        _foursquareURL = foursquareURL;
    }
    return self;
}

@end
