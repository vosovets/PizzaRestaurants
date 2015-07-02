//
//  PizzaPlaceDetailsViewController.m
//  PizzaRestaurants
//
//  Created by Vadim Osovets on 7/2/15.
//  Copyright (c) 2015 Vadim. All rights reserved.
//

// Controllers
#import "PizzaPlaceDetailsViewController.h"

// Model
#import "PizzaPlace.h"

@implementation PizzaPlaceDetailsViewController {
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UILabel *_checkinsCountLabel;
    __weak IBOutlet UILabel *_tipCountLabel;
    __weak IBOutlet UILabel *_usersCountLabel;
    __weak IBOutlet UILabel *_verifiedCountLabel;
    __weak IBOutlet UILabel *_latitudeLabel;
    __weak IBOutlet UILabel *_longitudeLabel;
    __weak IBOutlet UILabel *_isVerifiedLabel;
}

#pragma mark - Lifecylce

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Store Details";
    
    [self updateUI];
}

#pragma mark - Private

- (void)updateUI {
    _nameLabel.text = self.place.name;
    
    _checkinsCountLabel.text = [NSString stringWithFormat:@"Checkins: %d", [self.place.checkinsCount intValue]];
    _tipCountLabel.text = [NSString stringWithFormat:@"Tips: %d", [self.place.tipCount intValue]];
    _usersCountLabel.text = [NSString stringWithFormat:@"Total users: %d", [self.place.usersCount intValue]];

    _isVerifiedLabel.text = [self.place.verified boolValue] ? @"Verified!" : @"Not verified!";

    _latitudeLabel.text = [NSString stringWithFormat:@"Latitude: %.2f", [self.place.latitude doubleValue]];
    _longitudeLabel.text = [NSString stringWithFormat:@"Longitude: %.2f", [self.place.longitude doubleValue]];
}

@end
