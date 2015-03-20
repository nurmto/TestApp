//
//  FoursquareVenueInformation.m
//  TestApp
//
//  Created by Nurmela, Tomi on 17.3.2015.
//  Copyright (c) 2015 Nurmela, Tomi. All rights reserved.
//

#import "FoursquareVenueInformation.h"

@interface FoursquareVenueInformation () {

    NSString *_name;
    NSString *_address;
    NSArray *_formattedAddressArray;
    NSInteger _distance;
}
@end

@implementation FoursquareVenueInformation

- (id)initWithName:(NSString *)name
           address:(NSString *)address
  formattedAddress:(NSArray *)formattedAddress
          distance:(NSInteger)distance {

    self = [super init];
    if (self) {
        _name = name;
        _address = address;
        _formattedAddressArray = formattedAddress;
        _distance = distance;
    }
    return self;
}

- (NSString *)address {
    // Check which address information exists and return that
    if (_formattedAddressArray.count > 0) {
        NSString *address = @"";
        for (NSInteger i = 0; i < _formattedAddressArray.count; i++) {
            if (i > 0) {
                // Add space between address items
                address = [address stringByAppendingString:@" "];
            }
            address = [address stringByAppendingString:[_formattedAddressArray objectAtIndex:i]];
        }
        return address;
    }
    if (_address && _address.length > 0) {
        return _address;
    }
    return nil;
}
@end
