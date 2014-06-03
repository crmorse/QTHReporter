//
//  OQConnectionManager.h
//  QTHReporter
//
//  Created by Chris Morse on 6/2/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OQLocation;

@interface OQConnectionManager : NSObject

@property (nonatomic) BOOL useTestServer;

@property (nonatomic) BOOL isAuthenticated;
@property (nonatomic) BOOL isValid;
@property (nonatomic, strong) NSString* userID;
@property (nonatomic, strong) NSString* userName;
@property (nonatomic, strong) NSString* authToken;

+ (OQConnectionManager*) sharedOQConnectionManager;

- (void)login:(NSString*)username password:(NSString*)password completion:(void (^)(NSError* error))completion;
- (void)logout;

- (void)postLocation:(OQLocation*)location;

@end
