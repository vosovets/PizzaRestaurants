//
//  PizzaSearchComponent.m
//  PizzaRestaurants
//
//  Created by Vadim Osovets on 7/2/15.
//  Copyright (c) 2015 Vadim. All rights reserved.
//

// Components
#import "PizzaPlacesSearcher.h"

// 3rdParty
#import "MagicalRecord.h"

// CDModel
#import "PizzaPlace.h"

static NSString *const kFoursquareClientIDKey = @"XI01EV1VYKNVBY4F5ACSDAF5CEUYLKB5UFSZXLLREUXQOSP1";
static NSString *const kFoursquareClientSecretKey = @"EKMFFK4JX5CFIKBND1HGNZBV1RUIAOY50S15UJA3XI0XYCFQ";

static NSString *const kFoursquareBaseURL = @"https://api.foursquare.com/v2/";
static NSString *const kPizzaPlacesCategoryID = @"4bf58dd8d48988d1ca941735";

static NSString *const kGETMethodType = @"GET";
static NSString *const kAPIVersionMaxDate = @"20150702";

@implementation PizzaPlacesSearcher

#pragma mark - Public

+ (void)searchPizzaPlacesFromCoordinate:(CLLocationCoordinate2D)coordinate
                             withRadius:(CLLocationDistance)radius
                                  limit:(int32_t)limit
                            withSuccess:(PizzaPlacesSearcherSuccessBlock)success
                                failure:(PizzaPlacesSearcherFailureBlock)failure {
    
    NSString *ll = [NSString stringWithFormat:@"%.1f,%.1f", coordinate.latitude, coordinate.longitude];
    
    NSDictionary *params = @{@"ll" : ll,
                             @"limit" : @(limit),
                             @"radius" : @(radius),
                             @"categoryId" : kPizzaPlacesCategoryID,
                            };
    
    [self sendToPath:@"venues/explore"
          methodType:kGETMethodType
              params:params
             success:^(id response) {
                 // Return nearby pizza places to the caller.
                 NSArray *groups = response[@"groups"];
                 NSArray *pizzaPlaces = [groups firstObject][@"items"];
                 
                 NSManagedObjectContext *ctx = [NSManagedObjectContext MR_defaultContext];
                 
                 NSMutableArray *modelPizzaPlaces = [NSMutableArray new];
                 
                 for (NSDictionary *placeMeta in pizzaPlaces) {
                     NSDictionary *venueMeta = placeMeta[@"venue"];
                     NSString *placeID = venueMeta[@"id"];
                     
                     PizzaPlace *existingPlace = [PizzaPlace MR_findFirstByAttribute:@"placeId"
                                                                           withValue:placeID
                                                                           inContext:ctx];
                     
                     if (!existingPlace) {
                         existingPlace = [PizzaPlace MR_createEntityInContext:ctx];
                     }
                     
                     existingPlace.placeId = placeID;
                     existingPlace.latitude = venueMeta[@"location"][@"lat"];
                     existingPlace.longitude = venueMeta[@"location"][@"lng"];
                     existingPlace.name = venueMeta[@"name"];
                     existingPlace.verified = venueMeta[@"verified"];
                     existingPlace.checkinsCount = venueMeta[@"stats"][@"checkinsCount"];
                     existingPlace.tipCount = venueMeta[@"stats"][@"tipCount"];
                     existingPlace.usersCount = venueMeta[@"stats"][@"usersCount"];
                     
                     [modelPizzaPlaces addObject:existingPlace];
                 }
                 
                 [ctx MR_saveOnlySelfWithCompletion:^(BOOL contextDidSave, NSError *error) {
                     if (error) {
                         NSLog(@"Failed to save context! Fatal error: %@", error);
                         abort();
                     }
                     
                     !success ? : success([NSArray arrayWithArray:modelPizzaPlaces]);
                 }];
             } failure:failure];
}

#pragma mark - Private

+ (void)sendToPath:(NSString *)path
        methodType:(NSString *)methodType
            params:(NSDictionary *)params
           success:(PizzaPlacesSearcherSuccessBlock)success
           failure:(PizzaPlacesSearcherFailureBlock)failure {
    
    NSMutableDictionary *paramsWithMetaDict = [params mutableCopy];
    paramsWithMetaDict[@"client_id"] = kFoursquareClientIDKey;
    paramsWithMetaDict[@"client_secret"] = kFoursquareClientSecretKey;
    paramsWithMetaDict[@"v"] = kAPIVersionMaxDate;
    
    NSString *fullPath = [NSString stringWithFormat:@"%@%@", kFoursquareBaseURL, path];
    NSURL *pathURL = [NSURL URLWithString:fullPath];
    NSCParameterAssert(pathURL);
    
    NSURLRequest *request = [self requestWithURL:pathURL methodType:methodType params:paramsWithMetaDict];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue new]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               if (!connectionError) {
                                   // Try to parse response from server.
                                   NSError *parsingError = nil;
                                   NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:data
                                                                                              options:NSJSONReadingAllowFragments
                                                                                                error:&parsingError];
                                   
                                   if (!parsingError) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           // Checkout server status code.
                                           if ([parsedData[@"meta"][@"code"] integerValue] == 200) {
                                               !success ? : success(parsedData[@"response"]);
                                           } else {
                                               !failure ? : failure([NSError errorWithDomain:NSCocoaErrorDomain
                                                                                        code:0
                                                                                    userInfo:@{NSLocalizedDescriptionKey : @"Server error!"}]);
                                           }
                                       });
                                   } else {
                                       // Failed to parse response data from server.
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           !failure ? : failure([NSError errorWithDomain:NSCocoaErrorDomain
                                                                                    code:0
                                                                                userInfo:@{NSLocalizedDescriptionKey : @"Failed to parse received response!"}]);
                                       });
                                   }
                               } else {
                                   // Connection error occurred.
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       !failure ? : failure(connectionError);
                                   });
                               }
                           }];
}

+ (NSURLRequest *)requestWithURL:(NSURL *)URL methodType:(NSString *)methodType params:(NSDictionary *)params {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = methodType;
    
    NSMutableArray *queries = [NSMutableArray new];
    
    for (NSString *key in params) {
        NSString *value = params[key];

        NSString *percentEscapedKey = [self percentEscapedString:key];
        NSString *percentEscapedValue = [value isEqual:[NSNull null]] ? @"" : [self percentEscapedString:[value description]];
        
        [queries addObject:[NSString stringWithFormat:@"%@=%@", percentEscapedKey, percentEscapedValue]];
    }
    
    NSString *fullQueryString = [@"?" stringByAppendingString:[queries componentsJoinedByString:@"&"]];
    
    request.URL = [NSURL URLWithString:[request.URL.absoluteString stringByAppendingString:fullQueryString]];
    
    return request;
}

+ (NSString *)percentEscapedString:(NSString *)string {
    return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)string, (__bridge CFStringRef)@"[].", (__bridge CFStringRef)@":/?&=;+!@#$()',*", CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
}

@end
