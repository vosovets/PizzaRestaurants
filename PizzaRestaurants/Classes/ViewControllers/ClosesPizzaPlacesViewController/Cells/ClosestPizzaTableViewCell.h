//
//  ClosestPizzaTableViewCell.h
//  PizzaRestaurants
//
//  Created by Vadim Osovets on 7/2/15.
//  Copyright (c) 2015 Vadim. All rights reserved.
//

@import UIKit;

extern NSString *const kClosestPizzaPlaceReuseIdentifier;

@class PizzaPlace;

@interface ClosestPizzaTableViewCell : UITableViewCell

@property (nonatomic) PizzaPlace *place;
@property (nonatomic) CLLocationCoordinate2D userLocation;

@end
