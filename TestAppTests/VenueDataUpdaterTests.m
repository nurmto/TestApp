//
//  VenueDataUpdaterTests.m
//  TestApp
//
//  Created by Nurmela, Tomi on 19.3.2015.
//  Copyright (c) 2015 Nurmela, Tomi. All rights reserved.
//

#import "VenueDataUpdater.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface VenueDataUpdaterTests : XCTestCase

@end

@implementation VenueDataUpdaterTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSearch {

    // NOTE: Currently this test assumes that location service is enabled
    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    VenueDataUpdater *updater = [[VenueDataUpdater alloc] init];
    __block NSArray *resultArray;
    __block NSError *fetchError;
    [updater searchVenuesWithQuery:@"sushi" onComplete:^(NSArray *venues) {
        resultArray = venues;
        [expectation fulfill];
    } onFail:^(NSError *error) {
        fetchError = error;
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError *error) {
        if (error) {
            XCTAssert(NO, @"Test timed out");
        }
    }];
    XCTAssert(fetchError == nil, @"searche failed");
    XCTAssert(resultArray != nil, @"");
    XCTAssert(resultArray.count > 0, @"");
}

@end
