//
//  PizzaPlace.h
//  
//
//  Created by Vadim Osovets on 7/2/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface PizzaPlace : NSManagedObject

@property (nonatomic, retain) NSString *placeId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *verified;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSNumber *checkinsCount;
@property (nonatomic, retain) NSNumber *tipCount;
@property (nonatomic, retain) NSNumber *usersCount;

@end
