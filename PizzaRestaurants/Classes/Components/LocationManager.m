//
//  LocationManager.m
//  PizzaRestaurants
//
//  Created by Vadim Osovets on 7/2/15.
//  Copyright (c) 2015 Vadim. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager ()
<
CLLocationManagerDelegate
>
@end

@implementation LocationManager {
    CLLocationManager *_manager;
    
    LocationManagerMonitoringBlock _monitoringBlock;
    LocationManagerFailureBlock _failureBlock;
}

#pragma mark - Lifecycle

- (instancetype)init {
    if (self = [super init]) {
        _manager = [CLLocationManager new];
        _manager.delegate = self;
        
        [_manager requestWhenInUseAuthorization];
     
        _manager.distanceFilter = 25; // meters.
        _manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    }
    
    return self;
}

#pragma mark - Public

- (void)startMonitoringUserLocationWithCallback:(LocationManagerMonitoringBlock)callback
                                        failure:(LocationManagerFailureBlock)failureBlock {
    [_manager startUpdatingLocation];
    
    _monitoringBlock = callback;
    _failureBlock = failureBlock;
}

#pragma mark - <CLLocationManagerDelegate>

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newestLocation = [locations firstObject];
    
    if ([newestLocation horizontalAccuracy] > 0) {
        _userLocation = newestLocation;
        
        !_monitoringBlock ? : _monitoringBlock(newestLocation);
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    _failureBlock ? : _failureBlock(error);
}

@end
