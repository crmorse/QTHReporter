//
//  OQLocationManager.h
//  QTHReporter
//
//  Created by Chris Morse on 6/2/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@class OQLocation;



@interface OQLocationManager : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) NSMutableArray* locationHistory;  //used as a stack with maxLocationHistory depth
@property (nonatomic) int maxLocationHistory;


+ (OQLocationManager*) sharedOQLocationManager;

- (void)researchLocation:(OQLocation*)location;

@end
