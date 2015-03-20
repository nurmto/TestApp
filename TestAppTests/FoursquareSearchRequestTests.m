//
//  FoursquareSearchRequestTests.m
//  TestApp
//
//  Created by Nurmela, Tomi on 17.3.2015.
//  Copyright (c) 2015 Nurmela, Tomi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "BackendConfig.h"
#import "FoursquareSearchRequest.h"

@interface FoursquareSearchRequestTests : XCTestCase {
    BackendConfig *_config;
}
@end

@implementation FoursquareSearchRequestTests

- (void)setUp {
    [super setUp];
    _config = [[BackendConfig alloc] initWithClientID:@"CYEMKOM4OLTP5PHMOFVUJJAMWT5CH5G1JBCYREATW21XLLSZ"
                                         clientSecret:@"GYNP4URASNYRNRGXR5UEN2TGTKJHXY5FGSAXTIHXEUG1GYM2"
                                        foursquareURL:@"https://api.foursquare.com"];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    [super tearDown];
}

- (void)testRequest {

    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    __block NSError *requestError = nil;
    FoursquareSearchRequest *request = [[FoursquareSearchRequest alloc] initWithLatitude:40.7 longitude:-74 query:@"sushi"];
    [request sendWithConfig:_config onComplete:^(FoursquareBaseRequest *request) {
        [expectation fulfill];
    } onFail:^(FoursquareBaseRequest *request, NSError *error) {
        requestError = error;
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        if (error) {
            XCTAssert(NO, @"Test timed out");
        }
    }];
    XCTAssert(requestError == nil, @"Request failed");
    NSArray *venues = request.venueInfos;
    // Assume that we should have at least one item in a response.
    // For better testing we should find out some static venues from a specific location and compare resukt to them
    XCTAssert(venues.count > 0, @"Test timed out");
}

- (void)testRequestFail {

    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    __block NSError *requestError = nil;

    BackendConfig * invalidConfig = [[BackendConfig alloc] initWithClientID:@"1234OM4OLTP5PHMOFVUJJAMWT5CH5G1JBCYREATW21XLLSZ"
                                                               clientSecret:@"GYNP4URASNYRNRGXR5UEN2TGTKJHXY5FGSAXTIHXEUG1GYM2"
                                                              foursquareURL:@"https://api.foursquare.com"];
    FoursquareSearchRequest *request = [[FoursquareSearchRequest alloc] initWithLatitude:40.7 longitude:-74 query:@"sushi"];
    [request sendWithConfig:invalidConfig onComplete:^(FoursquareBaseRequest *request) {
        [expectation fulfill];
    } onFail:^(FoursquareBaseRequest *request, NSError *error) {
        requestError = error;
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        if (error) {
            XCTAssert(NO, @"Test timed out");
        }
    }];
    XCTAssert(requestError != nil, @"Request should failed");
    NSArray *venues = request.venueInfos;
    XCTAssert(venues == nil, @"");
}


@end