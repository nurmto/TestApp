//
//  main.m
//  TestApp
//
//  Created by Nurmela, Tomi on 16.3.2015.
//  Copyright (c) 2015 Nurmela, Tomi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        @try {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        } @catch (NSException *exception) {
            NSLog(@"%@", exception);
            NSLog(@"%@", exception.callStackSymbols);
            @throw exception;
        }
    }
}
