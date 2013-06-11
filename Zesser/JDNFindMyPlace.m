//
//  JDNFindMyPlace.m
//  Zesser
//
//  Created by Daniele Giove on 6/11/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import "JDNFindMyPlace.h"
#import <CoreLocation/CoreLocation.h>

@interface JDNFindMyPlace()<CLLocationManagerDelegate>
@end

@implementation JDNFindMyPlace{
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
}

- (id)init{
    self = [super init];
    if (self) {
        locationManager = [CLLocationManager new];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    }
    return self;
}

-(void)startSearchingCurrentLocation{
    if (self.delegate){
        [locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    currentLocation = [locations objectAtIndex:0];
    [locationManager stopUpdatingLocation];
    NSLog(@"Detected Location : %f, %f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:currentLocation
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       if (error){
                           NSLog(@"Geocode failed with error: %@", error);
                           return;
                       }
                       CLPlacemark *placemark = [placemarks objectAtIndex:0];
                       [self.delegate findMyPlaceDidFoundCurrentLocation:placemark];
                   }];
}

@end