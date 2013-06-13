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
    CLLocationManager *_locationManager;
}

-(CLLocationManager*)createLocationManager{
    _locationManager = [CLLocationManager new];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = 10.0f;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    return _locationManager;
}

-(void)startSearchingCurrentLocationWithAccuracy:(CLLocationAccuracy)accurancy{
    if ( self.delegate ) {
        _locationManager = [self createLocationManager];
        _locationManager.desiredAccuracy = accurancy;
        [_locationManager startUpdatingLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [_locationManager stopUpdatingLocation];
    _locationManager = nil;
    NSLog(@"Geocode failed with error: %@", error);
    [self.delegate findMyPlaceDidFoundCurrentLocation:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    [_locationManager stopUpdatingLocation];
    _locationManager = nil;
    
    CLLocation *currentLocation = [locations objectAtIndex:0];
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