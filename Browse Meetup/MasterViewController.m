//
//  MasterViewController.m
//  Read JSON
//
//  Created by TAMIM Ziad on 8/16/13.
//  Copyright (c) 2013 TAMIM Ziad. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailCell.h"

#import "OQLocation.h"
#import "OQLocationManager.h"

@implementation MasterViewController {
    OQLocationManager* locationManager;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    locationManager = [OQLocationManager sharedOQLocationManager];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData:)
                                                 name:@"OQLocationManagerAddedLocations"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData:)
                                                 name:@"OQLocationManagerCompletedLocationResearch"
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super viewWillDisappear:animated];
}

- (void)reloadData:(NSNotification*)notification {
    NSLog(@"Notification received: %@", notification);
    [self.tableView reloadData];
}

#pragma mark - Table View
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return locationManager.locationHistory.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    OQLocation* location = [locationManager.locationHistory objectAtIndex:indexPath.row];
    [cell configureWithLocation:location];

    return cell;
}

@end
