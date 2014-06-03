//
//  OQConnectionManager.m
//  QTHReporter
//
//  Created by Chris Morse on 6/2/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "OQConnectionManager.h"

#include "SynthesizeSingleton.h"
#import <CoreLocation/CoreLocation.h>

#import "OQLocation.h"


NSString* TEST_APISERVER = @"test.1q.com";
NSString* PROD_APISERVER = @"1q.com";

@interface OQConnectionManager() {
    NSString* targetServer;
}
@end


@implementation OQConnectionManager

SYNTHESIZE_SINGLETON_FOR_CLASS(OQConnectionManager)

- (OQConnectionManager*)init {
    self = [super init];
    if (self) {
        _useTestServer = YES;
        targetServer = TEST_APISERVER;
    }
    return self;
}

- (void)setUseTestServer:(BOOL)useTestServer {
    _useTestServer = useTestServer;
    targetServer = _useTestServer ? TEST_APISERVER : PROD_APISERVER;
}

- (void)login:(NSString *)username password:(NSString *)password completion:(void (^)(NSError* error))completion {

    //Setup the request.
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/user/authenticate", targetServer]]];
    urlRequest.HTTPMethod = @"POST";
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    // Convert the data and set the request's HTTPBody
    NSError* error = nil;
    NSDictionary* rawData = @{@"username": username,
                              @"password": password};

    NSData* jsonRequest = [NSJSONSerialization dataWithJSONObject:rawData
                                                          options:NSJSONWritingPrettyPrinted
                                                            error:&error];
    //TODO:Check error result better
    if(error) {
        NSLog(@"Error creating JSON for API request: %@", error);

        //Call caller's block with results and bailout
        completion(error);
        return;
    }
    urlRequest.HTTPBody = jsonRequest;
    urlRequest.timeoutInterval = 10.0; //Since we're firing synchronous we better provide a way out
    NSLog(@"urlRequest: %@", urlRequest);

    // Create url connection and fire request
    NSHTTPURLResponse* urlResponse = nil;
    // !!!: Normally API calls should be asynchronous but since you can't do anything
    // until after we have a successful login this one will be synchronous for simplicity
    NSData* responseData = [NSURLConnection sendSynchronousRequest:urlRequest
                                                 returningResponse:&urlResponse
                                                             error:&error];
    NSLog(@"urlResponse: %@", [NSString stringWithUTF8String:[responseData bytes]]);

    //TODO:Check error result better
    if(error) {
        NSLog(@"Error calling API service: %@", error);

        //Call caller's block with results and bailout
        completion(error);
        return;
    }

    if (urlResponse.statusCode == 200) {
        //Successful request: Parse results
        NSDictionary *jsonResults = [NSJSONSerialization JSONObjectWithData:responseData
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:&error];

        if (error) {
            NSLog(@"Error parsing jsonResults: %@", error);
        } else {
            self.userID = [jsonResults objectForKey:@"_id"];
            self.authToken = [jsonResults objectForKey:@"Auth-Token"];
            self.isValid = [[jsonResults objectForKey:@"isValid"] boolValue];
            self.isAuthenticated = YES;

            NSLog(@"Login success! id: %@, token: %@", self.userID, self.authToken);
        }
    } else {
        [self logout]; //clears up state
        if (!error) {
            error = [NSError errorWithDomain:@"Login failure" code:401 userInfo:@{@"response": responseData}];
        }
    }

    //Call caller's block with results
    completion(error);
}

- (void)logout {
    self.isValid = NO;
    self.isAuthenticated = NO;
    self.userID = nil;
    self.userName = nil;
    self.authToken = nil;
}

- (void)postLocation:(OQLocation *)oqLocation {
    //If we aren't logged in there's nothing we can do.
    if (!self.isAuthenticated) {
        return;
    }

    //Setup the request.
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/user/%@/location", targetServer, self.userID]]];
    urlRequest.HTTPMethod = @"POST";
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:self.authToken      forHTTPHeaderField:@"Auth-Token"];

    // Convert the data and set the request's HTTPBody
    NSError* error = nil;
    NSDictionary* rawData = @{@"longitude": oqLocation.longitude,
                              @"latitude":  oqLocation.latitude,
                              @"accuracy":  oqLocation.accuracy};

    NSData* jsonRequest = [NSJSONSerialization dataWithJSONObject:rawData
                                                          options:NSJSONWritingPrettyPrinted
                                                            error:&error];
    //TODO:Check error result better
    if(error) {
        NSLog(@"Error creating JSON for API request: %@", error);
        return;
    }
    urlRequest.HTTPBody = jsonRequest;
    urlRequest.timeoutInterval = 5.0; //We are firing asynchronous but it's better not to waste radio power if it's probably goign to fail anyway.
    NSLog(@"urlRequest: %@", urlRequest);

    // Create url connection and fire request
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSLog(@"%@ Posting new user location: %@", (error ? @"FAILED" : @"SUCCESS"), oqLocation);
        NSLog(@"\t Response data: %@", [NSString stringWithUTF8String:[data bytes]]);

        oqLocation.hasReportedLocation = (!error);
    }];
}

@end
