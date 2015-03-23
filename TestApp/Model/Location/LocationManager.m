//
//  LocationManager.m
//  TestApp
//
//  Created by Nurmela, Tomi on 16.3.2015.
//  Copyright (c) 2015 Nurmela, Tomi. All rights reserved.
//

#import "LocationManager.h"

#import <CoreLocation/CoreLocation.h>
#import <Foundation/NSMapTable.h>

// Class for holding the block handlers for each location observer
// Defined inside source here, because this should be used only internally by LocationManager
@interface CurrentLocationObserverInfo : NSObject
@property (nonatomic, copy) LocationOnCompleteFunction onComplete;
@property (nonatomic, copy) LocationOnFailedFunction onFail;
@end
@implementation CurrentLocationObserverInfo
@synthesize onComplete, onFail;
@end


@interface LocationManager () <CLLocationManagerDelegate> {

    CLLocationManager *_locationManager;
    NSMapTable *_currentLocationObserverToInfoMap;
}
@end

@implementation LocationManager

+ (LocationManager*)sharedLocationManager {

    static LocationManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LocationManager alloc] init];
    });
    return instance;
}

- (id)init {

    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
        _currentLocationObserverToInfoMap = [LocationManager mapTableForLocationObserver];
    }
    return self;
}

+ (NSMapTable *)mapTableForLocationObserver {
    // Use weak keys, so that observers don't need to implement copyWithZone -method
    return [NSMapTable weakToStrongObjectsMapTable];
}

+ (BOOL)isUnauthorizedToUseLocationWithStatus:(CLAuthorizationStatus)status {
    if ((status == kCLAuthorizationStatusRestricted) ||
        (status == kCLAuthorizationStatusDenied)) {
        return YES;
    }
    return NO;
}

- (void)currentLocationWithObserver:(__weak id)observer onComplete:(LocationOnCompleteFunction) onComplete onFailed:(LocationOnFailedFunction)onFailed {

    NSAssert(onComplete != nil, @"onComplete is nil");
    NSAssert(onFailed != nil, @"onFailed is nil");
    NSAssert(observer != nil, @"observer is nil");

    CurrentLocationObserverInfo *info = CurrentLocationObserverInfo.new;
    // copy blocks
    info.onComplete = onComplete;
    info.onFail = onFailed;
    [_currentLocationObserverToInfoMap setObject:info forKey:observer];

    if (![CLLocationManager locationServicesEnabled]) {
        [self locationDidFailWithError:[NSError TestAppErrorWithErrorCode:kTestAppErrorLocationServicesDisabled]];
    } else {
        if ([LocationManager isUnauthorizedToUseLocationWithStatus:[CLLocationManager authorizationStatus]]) {
            [self locationDidFailWithError:[NSError TestAppErrorWithErrorCode:kTestAppErrorLocationUnauthorized]];

        } else {
            // We are not currently receiving location updates. Start it now
            if (([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) &&
                [_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [_locationManager requestWhenInUseAuthorization];
            }
            [_locationManager startUpdatingLocation];
        }
    }
}

- (void)cancelWithObserver:(__weak id)observer {

    [_currentLocationObserverToInfoMap removeObjectForKey:observer];
    if (_currentLocationObserverToInfoMap.count == 0) {
        // No observers. We can stop updating location immediately
        [_locationManager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {

    if ([LocationManager isUnauthorizedToUseLocationWithStatus:status]) {
        [self locationDidFailWithError:[NSError TestAppErrorWithErrorCode:kTestAppErrorLocationUnauthorized]];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    if (locations.count > 0) {
        CLLocation *currentLocation  =locations.lastObject;
        if (currentLocation) {
            NSLog(@"Current location, lat:%f, lng:%f", [currentLocation coordinate].latitude, [currentLocation coordinate].longitude);
            [_locationManager stopUpdatingLocation];
            // Use temporal map for avoiding situation that someone is trying update maptable during enumeration (inside callback)
            NSMapTable *map = _currentLocationObserverToInfoMap;
            _currentLocationObserverToInfoMap = [LocationManager mapTableForLocationObserver];
            for (CurrentLocationObserverInfo *info in map.objectEnumerator) {
                info.onComplete([currentLocation coordinate].latitude, [currentLocation coordinate].longitude);
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self locationDidFailWithError:error];
}

- (void)locationDidFailWithError:(NSError *)error {

    NSLog(@"Retrieving location info failed: %@", error);
    [_locationManager stopUpdatingLocation];
    NSMapTable *map = _currentLocationObserverToInfoMap;
    _currentLocationObserverToInfoMap = [LocationManager mapTableForLocationObserver];
    for (CurrentLocationObserverInfo *info in map.objectEnumerator) {
        info.onFail(error);
    }
}


@end
