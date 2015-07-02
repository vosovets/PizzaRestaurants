//
//  ClosestPizzaTableViewCell.m
//  PizzaRestaurants
//
//  Created by Vadim Osovets on 7/2/15.
//  Copyright (c) 2015 Vadim. All rights reserved.
//

@import CoreLocation;

// Cells
#import "ClosestPizzaTableViewCell.h"

// CDModel
#import "PizzaPlace.h"

NSString *const kClosestPizzaPlaceReuseIdentifier = @"ClosestPizzaPlace";

@implementation ClosestPizzaTableViewCell {
    
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UILabel *_checkinsCountLabel;
    __weak IBOutlet UILabel *_tipCountLabel;
    __weak IBOutlet UILabel *_usersCountLabel;
    __weak IBOutlet UILabel *_isVerifiedLabel;
    __weak IBOutlet UILabel *_howFarMeters;
}

- (void)setPlace:(PizzaPlace *)place {
    if (_place != place) {
        _place = place;
        

        _nameLabel.text = _place.name;
        _checkinsCountLabel.text = [NSString stringWithFormat:@"Checkins: %d", [_place.checkinsCount intValue]];
        _tipCountLabel.text = [NSString stringWithFormat:@"Tips: %d", [_place.tipCount intValue]];
        _usersCountLabel.text = [NSString stringWithFormat:@"Total users: %d", [_place.usersCount intValue]];

        _isVerifiedLabel.text = [_place.verified boolValue] ? @"Verified!" : @"Not verified!";
        
        _howFarMeters.text = @"Unknown";
    }
}

- (void)setUserLocation:(CLLocationCoordinate2D)userLocation {
    _userLocation = userLocation;
    
    CLLocation *clUserLocation = [[CLLocation alloc] initWithLatitude:userLocation.latitude
                                                          longitude:userLocation.longitude];
    
    CLLocation *clPlaceLocation = [[CLLocation alloc] initWithLatitude:[_place.latitude doubleValue]
                                                             longitude:[_place.longitude doubleValue]];
    
    _howFarMeters.text = [NSString stringWithFormat:@"%.0f meters away.", [clPlaceLocation distanceFromLocation:clUserLocation]];
}

@end
