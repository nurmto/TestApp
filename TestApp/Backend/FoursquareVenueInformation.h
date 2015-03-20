//
//  FoursquareVenueInformation.h
//  TestApp
//
//  Created by Nurmela, Tomi on 17.3.2015.
//  Copyright (c) 2015 Nurmela, Tomi. All rights reserved.
//

// Value that is used when distance is not known
#define kUnknownDistance -1

// Class for holding venue specific information
@interface FoursquareVenueInformation : NSObject

@property(nonatomic, readonly) NSString *name;
// Address information, can be nil.
@property(nonatomic, readonly) NSString *address;
// Distance is in meters. Returns kUnknownDistance, if distance is not known
@property(nonatomic, readonly) NSInteger distance;

// Distance is measured in meters. Biggest value that we are able to represent by using 32-bit integer is
// 2147483647 -> ~2147483 kilometers. Current assumption is that foursquare returns only venues that locate in earth
- (id)initWithName:(NSString *)name
           address:(NSString *)address
  formattedAddress:(NSArray *)formattedAddress
          distance:(NSInteger)distance;

@end
