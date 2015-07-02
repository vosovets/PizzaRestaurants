//
//  PizzaSearchComponent.h
//  PizzaRestaurants
//
//  Created by Vadim Osovets on 7/2/15.
//  Copyright (c) 2015 Vadim. All rights reserved.
//

@import Foundation;
@import CoreLocation;

typedef void (^PizzaPlacesSearcherSuccessBlock) (NSArray *nearestPizzaPlaces);
typedef void (^PizzaPlacesSearcherFailureBlock) (NSError *error);

@interface PizzaPlacesSearcher : NSObject

/**
 *  Fetches nearby pizza places
 */
+ (void)searchPizzaPlacesFromCoordinate:(CLLocationCoordinate2D)coordinate
                             withRadius:(CLLocationDistance)radius
                                  limit:(int32_t)limit
                            withSuccess:(PizzaPlacesSearcherSuccessBlock)success
                                failure:(PizzaPlacesSearcherFailureBlock)failure;

@end
