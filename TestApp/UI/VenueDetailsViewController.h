//
//  VenueDetailsViewController.h
//  TestApp
//
//  Created by Nurmela, Tomi on 18.3.2015.
//  Copyright (c) 2015 Nurmela, Tomi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FoursquareVenueInformation;

// For showing detailed information about venue
@interface VenueDetailsViewController : UIViewController

// Set venue information that needs to be shown
- (void)setVenueInformation:(FoursquareVenueInformation *)venueInfo;

@end
