//
//  VenueDataUpdater.h
//  TestApp
//
//  Created by Nurmela, Tomi on 17.3.2015.
//  Copyright (c) 2015 Nurmela, Tomi. All rights reserved.
//

// Called on success. Venus array contains FoursquareVenueInformation objects. Objects are sorted so that nearest venue is at index 0
typedef void (^VenueSearchFunction)(NSArray *venues);
// Called when some error occurred.
typedef void (^VenueSearchFailedFunction)(NSError *error);

// For searching venues that are near of current location
@interface VenueDataUpdater : NSObject

// Triggers search. Asynchronous method. Can be cancelled using cancel -method
// Only for single user. New search should not be triggered until previous search is completed or cancelled
// query    - query that is used as a search criteria for venues
- (void)searchVenuesWithQuery:(NSString *)query
                   onComplete:(VenueSearchFunction)onComplete
                       onFail:(VenueSearchFailedFunction)onFail;

// For canceling searchVenuesWithQuery -method
- (void)cancel;

@end
