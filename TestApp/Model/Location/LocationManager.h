//
//  LocationManager.h
//  TestApp
//
//  Created by Nurmela, Tomi on 16.3.2015.
//  Copyright (c) 2015 Nurmela, Tomi. All rights reserved.
//

typedef void (^LocationOnCompleteFunction)(double latitude, double longitude);
typedef void (^LocationOnFailedFunction)(NSError *error);

// Singleton instance for getting current location
@interface LocationManager : NSObject

// Return a singleton instance of a location manager
+ (LocationManager *)sharedLocationManager;

// For getting current location. Success or failed block may be called synchronously or asynchronously. Asynchronous request can be cancelled
// by using cancelWithObserver -method. Completion will be notified only once by calling onComplete or onFailed block.
// nil parameters are not allowed
- (void)currentLocationWithObserver:(__weak id)observer onComplete:(LocationOnCompleteFunction) onComplete onFailed:(LocationOnFailedFunction)onFailed;

// Cancel asynchronous currentLocationWithObserver -method
- (void)cancelWithObserver:(__weak id)observer;

@end
