//
//  LocationManager.h
//  PizzaRestaurants
//
//  Created by Vadim Osovets on 7/2/15.
//  Copyright (c) 2015 Vadim. All rights reserved.
//

@import CoreLocation;

typedef void (^LocationManagerMonitoringBlock) (CLLocation *newUserLocation);
typedef void (^LocationManagerFailureBlock) (NSError *error);

@interface LocationManager : NSObject

@property (nonatomic, readonly) CLLocation *userLocation;

- (void)startMonitoringUserLocationWithCallback:(LocationManagerMonitoringBlock)callback
                                        failure:(LocationManagerFailureBlock)failureBlock;

@end
