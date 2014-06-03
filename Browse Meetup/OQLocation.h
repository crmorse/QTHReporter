//
//  OQLocation.h
//  QTHReporter
//
//  Created by Chris Morse
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@interface OQLocation : NSObject {
}


@property (nonatomic) BOOL hasResearchedLocation; //yes if we've attempted to geocode and/or venue lookup this location
@property (nonatomic) BOOL hasReportedLocation; //yes if we've successfully uploaded this location


@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSString *venue;
@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *city;

+ (OQLocation*)locationWithCLLocation:(CLLocation*)location;

//Convenience methods
- (NSNumber*)latitude;
- (NSNumber*)longitude;
- (NSNumber*)accuracy;


@end
