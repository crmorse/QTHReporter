//
//  OQLocationManager.m
//  QTHReporter
//
//  Created by Chris Morse on 6/2/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "OQLocationManager.h"

#include "SynthesizeSingleton.h"

#import "OQLocation.h"
#import "OQConnectionManager.h"

@interface OQLocationManager() <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

@end


@implementation OQLocationManager {
    NSOperationQueue* researchQueue;
}

SYNTHESIZE_SINGLETON_FOR_CLASS(OQLocationManager)

- (OQLocationManager*)init {
    self = [super init];
    if (self) {
        _maxLocationHistory = 20;
        _locationHistory = [NSMutableArray new];
        researchQueue = [[NSOperationQueue alloc] init];

        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;

        if ([CLLocationManager locationServicesEnabled]) {
            [self setTrackingStrategyHighestResolution];
        }
    }
    return self;
}

- (void)setTrackingStrategyLowestPower {
    [self.locationManager startMonitoringSignificantLocationChanges];
    [self.locationManager stopUpdatingLocation];
}

- (void)setTrackingStrategyHighestResolution {
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager startUpdatingLocation];
    [self.locationManager startMonitoringSignificantLocationChanges];
//    [self.locationManager startMonitoringForRegion:NULL];
}

- (void)setTrackingStrategyIntelligentBlend {
    //Note, requires last location to have successfully reverse-geodecoded or venue information

/* BEGIN Pseudocode

    I) If current location is relatively static:
       1) Extract location's perimeter based on reverse-geocode or venue database
       2) Set distanceFilter equal to best fitting circumference of perimeter
       3) Setup geo-fence around perimeter

    II) If current location indicates linear travel
       1) Set distanceFilter inversely proportial to speed
          * i.e. much smaller increments if speed is medium-slow
          * much larger increments if speed is very fast
          * Set a floor so that increments are never smaller than 5 minutes

    III) If location history indicates broken travel (i.e. large gaps)
       * Assume phone has limited connectivity; reduce drain as much as possible
       1) startMonitoringSignificantLocationChanges
       2) Turn off high-resolution and geo-fencing
       3) Regularly check for a return to routine tracking

END Pseudocode */

    //Quick and dirty demo code
    self.locationManager.distanceFilter = 100;        //medium value of 100 Meters
    [self.locationManager startUpdatingLocation];
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)reanalyzeLocationHistory {
    //Here we look at the most recent location information to see if we need to change our tracking strategy

    //Set strategy to HighestResolution if:
    //      battery is high && (speed is high || venue is unknown)
    [self setTrackingStrategyHighestResolution];

    //Set strategy to LowestPower if:
    //      battery is low || (speed is low && change is low)
//    [self setTrackingStrategyLowestPower];

    //Else set strategy to Intelligent blend
//    [self setTrackingStrategyIntelligentBlend];

    //If venue change detected post notification
    if (YES /*venueChanged*/) {
        // !!!: I normally would never call from one manager into another one like this. There
        // should be a controller object mediating. However, the design specs call for location
        // notifications to happen even in the background and this call path is the only one that
        // will occur while in background mode.
        [[OQConnectionManager sharedOQConnectionManager] postLocation:self.locationHistory.lastObject];

// ???: Disabling this NSNotification because I don't know what the behavior will be when the app is backgrounded. Need to test.
//        //Always post NSNotifications on the MainThread.  You have been warned!
//        [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotificationName:) withObject:@"OQLocationManagerVenueChanged" waitUntilDone:NO];
    }
}

#pragma mark - Public Interface
- (void)researchLocation:(OQLocation*)location {

    [researchQueue addOperationWithBlock:^{
        if (!location.hasResearchedLocation) {
            //TODO: Do reverse-geocoding & venue lookup here

            //Always post NSNotifications on the MainThread.  You have been warned!
            [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotificationName:) withObject:@"OQLocationManagerCompletedLocationResearch" waitUntilDone:NO];
        }
    }];
}


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorized) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kCLAuthorizationStatusAuthorized" object:self];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
//    NSLog(@"Got new locations: %@", locations);

    //Add new location(s)
    for (CLLocation* newLoc in locations) {
        OQLocation* oqLoc = [OQLocation locationWithCLLocation:newLoc];
        [self.locationHistory addObject:oqLoc];
    }

    //Purge any expired locations (NB! not the most efficient code)
    while (self.locationHistory.count > self.maxLocationHistory) {
        [self.locationHistory removeObjectAtIndex:0];
    }

    //Analyze new history
    [self reanalyzeLocationHistory];

    //Always post NSNotifications on the MainThread.  You have been warned!
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotificationName:) withObject:@"OQLocationManagerAddedLocations" waitUntilDone:NO];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    //Need to react to errors here in case our geo-fences don't work or user has disabled some forms of tracking.
    //CLError
    NSLog(@"Got location error: %@", error);
}

@end
