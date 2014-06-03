//
//  DetailCell.m
//  BrowseMeetup
//
//  Created by TAMIM Ziad on 8/16/13.
//  Copyright (c) 2013 TAMIM Ziad. All rights reserved.
//

#import "DetailCell.h"

#import "OQLocation.h"

@implementation DetailCell

- (void)configureWithLocation:(OQLocation*)location {
    //formatting gymnastics!
    NSString* city = location.city ? location.city : @"";
    NSString* comma = location.city ? @"," : @"";
    NSString* country = location.country ? location.country : @"";

    //typing tests
    self.locationLabel.text = location.description;
    self.venueLabel.text = @"Geodecoded venue"; //location.venue;
    self.geocodeLabel.text = [NSString stringWithFormat:@"%@%@ %@", city, comma, country];
    self.descriptionLabel.text = [NSString stringWithFormat:@"Tracked at: %@", location.location.timestamp];
}

@end
