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

-(CLLocationManager*)createLocationManager{
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    locationManager.distanceFilter = 10.0f;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    return locationManager;
}

-(void)startSearchingCurrentLocationWithAccuracy:(CLLocationAccuracy)accurancy{
    if ( self.delegate ) {
        locationManager = [self createLocationManager];
        locationManager.desiredAccuracy = accurancy;
        [locationManager startUpdatingLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [locationManager stopUpdatingLocation];
    locationManager = nil;
    NSLog(@"Geocode failed with error: %@", error);
    [self.delegate findMyPlaceDidFoundCurrentLocation:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    [locationManager stopUpdatingLocation];
    locationManager = nil;
    
    currentLocation = [locations objectAtIndex:0];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:currentLocation
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       if (error){
                           NSLog(@"Geocode failed with error: %@", error);
                           [self.delegate findMyPlaceDidFoundCurrentLocation:nil];
                           return;
                       }
                       CLPlacemark *placemark = [placemarks objectAtIndex:0];
                       [self.delegate findMyPlaceDidFoundCurrentLocation:placemark];
                   }];
}

@end