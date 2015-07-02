//
//  ViewController.m
//  PizzaRestaurants
//
//  Created by Vadim Osovets on 7/2/15.
//  Copyright (c) 2015 Vadim. All rights reserved.
//

// Controllers
#import "ClosestPizzaPlacesViewController.h"
#import "PizzaPlaceDetailsViewController.h"

// Components
#import "PizzaPlacesSearcher.h"
#import "LocationManager.h"

// CDModel
#import "PizzaPlace.h"

// Categories
#import "UIViewController+ExtendedSegue.h"

// Cells
#import "ClosestPizzaTableViewCell.h"

static NSString *const kPizzaPlaceDetailsSegueIdentifier = @"PizzaPlaceDetailsSegue";

static CLLocationDistance const kDefaultSearchRadius = 1000.0f;
static int32_t const kDefaultQueryLimit = 10;

@interface ClosestPizzaPlacesViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>
@end

@implementation ClosestPizzaPlacesViewController {
    LocationManager *_locationManager;
    
    NSArray *_nearbyPizzaPlaces;
    
    __weak IBOutlet UITableView *_pizzaPlacesTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Nearby Pizza Stores";
    
    [_pizzaPlacesTableView registerNib:[UINib nibWithNibName:NSStringFromClass([ClosestPizzaTableViewCell class]) bundle:nil]
                forCellReuseIdentifier:kClosestPizzaPlaceReuseIdentifier];
    
    _locationManager = [LocationManager new];
    
    [_locationManager startMonitoringUserLocationWithCallback:^(CLLocation *newUserLocation) {
        [_pizzaPlacesTableView reloadData];
        
        PizzaPlacesSearcherSuccessBlock searcherSuccessBlock = ^(NSArray *pizzaPlaces) {
            // Sort places by name.
            _nearbyPizzaPlaces = [pizzaPlaces sortedArrayUsingComparator:^NSComparisonResult(PizzaPlace *place1,
                                                                                             PizzaPlace *place2) {
                return [place1.name compare:place2.name];
            }];
            
            [_pizzaPlacesTableView reloadData];
        };
        
        [PizzaPlacesSearcher searchPizzaPlacesFromCoordinate:newUserLocation.coordinate
                                                  withRadius:kDefaultSearchRadius
                                                       limit:kDefaultQueryLimit
                                                 withSuccess:searcherSuccessBlock
                                                     failure:^(NSError *error) {
                                                         [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                                     message:error.localizedDescription
                                                                                    delegate:nil
                                                                           cancelButtonTitle:@"OK"
                                                                           otherButtonTitles:nil] show];
                                                     }];
    } failure:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Failed to track user location"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }];
    

}

#pragma mark - <UITableViewDelegate&Datasource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _nearbyPizzaPlaces.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ClosestPizzaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kClosestPizzaPlaceReuseIdentifier];
    
    cell.place = _nearbyPizzaPlaces[indexPath.row];
    cell.userLocation = _locationManager.userLocation.coordinate;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self performSegueWithIdentifier:kPizzaPlaceDetailsSegueIdentifier
                     prepareCallback:^(id sourceController, PizzaPlaceDetailsViewController *detailsController) {
                         detailsController.place = _nearbyPizzaPlaces[indexPath.row];
                     }];
}

@end
