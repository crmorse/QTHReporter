//
//  OQLocation.m
//  QTHReporter
//
//  Created by Chris Morse
//

#import "OQLocation.h"

#import "OQLocationManager.h"

@implementation OQLocation {
}

+ (OQLocation*)locationWithCLLocation:(CLLocation*)location {
    OQLocation* oqloc = [OQLocation new];

    oqloc.location = location;
    [[OQLocationManager sharedOQLocationManager] researchLocation:oqloc]; //async lookup

    return oqloc;
}

- (NSString*)description {
    NSString* description = [NSString stringWithFormat:@"%gº, %gº, ±%g M", self.location.coordinate.latitude, self.location.coordinate.longitude, self.location.altitude];
    return description;
}

- (NSNumber*)latitude {
    NSNumber* latitude = [NSNumber numberWithDouble:self.location.coordinate.latitude];
    return latitude;
}

- (NSNumber*)longitude {
    NSNumber* longitude = [NSNumber numberWithDouble:self.location.coordinate.longitude];
    return longitude;
}

- (NSNumber*)accuracy {
    //Only horizontal accuracy really matters for our purposes
    NSNumber* accuracy = [NSNumber numberWithDouble:self.location.horizontalAccuracy];
    return accuracy;
}


@end
