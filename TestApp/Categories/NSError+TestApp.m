//
//  NSError+TestApp.m
//  TestApp
//
//  Created by Nurmela, Tomi on 17.3.2015.
//  Copyright (c) 2015 Nurmela, Tomi. All rights reserved.
//

#import "NSError+TestApp.h"

@implementation NSError (TestApp)

+ (NSError *)TestAppErrorWithErrorCode:(NSInteger)errorCode {
    
    NSString *description = @"";
    switch (errorCode) {
        case kTestAppErrorLocationServicesDisabled: {
            description = @"ERROR_LOCATION_SERVICES_DISABLED";
            break;
        }
        case kTestAppErrorLocationUnauthorized: {
            description = @"ERROR_LOCATION_SERVICES_UNAUTHORIZED";
            break;
        }
        default:
            NSAssert(NO, @"Unknown error code definition");
    }
    return [NSError TestAppErrorWithErrorCode:errorCode description:description];
}

+ (NSError *)TestAppErrorWithErrorCode:(NSInteger)errorCode description:(NSString *)description {

    return [NSError errorWithDomain:kTestAppErrorDomain
                               code:errorCode
                           userInfo:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(description, @""), NSLocalizedDescriptionKey, nil]];
}

@end
