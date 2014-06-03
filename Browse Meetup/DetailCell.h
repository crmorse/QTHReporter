//
//  DetailCell.h
//  BrowseMeetup
//
//  Created by TAMIM Ziad on 8/16/13.
//  Copyright (c) 2013 TAMIM Ziad. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OQLocation;

@interface DetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *venueLabel;
@property (weak, nonatomic) IBOutlet UILabel *geocodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

- (void)configureWithLocation:(OQLocation*)location;

@end
