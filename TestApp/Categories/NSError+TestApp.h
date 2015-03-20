//
//  NSError+TestApp.h
//  TestApp
//
//  Created by Nurmela, Tomi on 17.3.2015.
//  Copyright (c) 2015 Nurmela, Tomi. All rights reserved.
//

static const NSInteger kTestAppErrorBase = -10000;
static NSString *const kTestAppErrorDomain = @"TestAppErrorDomain";

typedef NS_ENUM(NSInteger, TestAppErrorCode) {
    // Device location service setting is disabled
    kTestAppErrorLocationServicesDisabled   = kTestAppErrorBase,
    // User has not granted application to access location data
    kTestAppErrorLocationUnauthorized       = kTestAppErrorBase -1,

    // Backend communication related generic error
    kTestAppBackendErrorGeneric             = kTestAppErrorBase -100
};

@interface NSError (TestApp)

// Initializes application domain specific error
+ (NSError *)TestAppErrorWithErrorCode:(NSInteger)errorCode;
// Initializes application domain specific error with a predefined description text
+ (NSError *)TestAppErrorWithErrorCode:(NSInteger)errorCode description:(NSString *)description;

@end
