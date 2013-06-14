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

@property (strong,nonatomic) CLLocationManager  *locationManager;
@property (strong,nonatomic) CLLocation         *lastUpdatedLocation;
@property (atomic)           BOOL               decoded;

@end

@implementation JDNFindMyPlace

-(CLLocationManager*)locationManager{
    if ( !_locationManager ){
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    return _locationManager;
}

-(void)startSearchingCurrentLocationWithAccuracy:(CLLocationAccuracy)accurancy{
    if ( self.delegate ) {
        if ( ! [CLLocationManager locationServicesEnabled] ||
            [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized ) {
            [self.delegate findMyPlaceDidFoundCurrentLocation:nil];
            return;
        }
        self.decoded = NO;
        [self performSelector:@selector(searchComplete:) withObject:NO afterDelay:10];
        self.locationManager.desiredAccuracy = accurancy;
        [self.locationManager startUpdatingLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [self.locationManager stopUpdatingLocation];
    self.decoded = NO;
    [self.delegate findMyPlaceDidFoundCurrentLocation:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    NSLog(@"ACC %f" , self.lastUpdatedLocation.horizontalAccuracy);
    
    /* Save the new location to an instance variable */
    self.lastUpdatedLocation = [locations lastObject];
    /* Refuse updates more than a minute old */
    if (abs([self.lastUpdatedLocation.timestamp timeIntervalSinceNow]) > 60.0) {
        return;
    }
    
    /* If it's, accurate enough, cancel the timer */
    if (self.lastUpdatedLocation.horizontalAccuracy < 1000) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        /* And fire it manually instead */
        [self searchComplete:YES];
    }
}


-(void)searchComplete:(BOOL)fast {
    NSLog(@"FINISHED! %@", fast?@"Y":@"N");
    [self.locationManager stopUpdatingLocation];
    // decode once a search-loop
    if ( self.decoded ) return;
    self.decoded = YES;
    [self decodeCurrentLocation];
}

-(void)decodeCurrentLocation{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:self.lastUpdatedLocation
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       if (error){
                           [self.delegate findMyPlaceDidFoundCurrentLocation:nil];
                           return;
                       }
                       
                       CLPlacemark *placemark = [placemarks objectAtIndex:0];
                       NSString *place = placemark.locality;
                       
                       // fix just home!
                       if ( [placemark.postalCode isEqualToString:@"20060"] && [placemark.locality isEqualToString:@"Bettola"] ){
                           place = @"Pozzo D'Adda";
                       }
                       NSLog(@"Place: (%@) - %@", place, placemark);
                       
                       [self.delegate findMyPlaceDidFoundCurrentLocation:place];
                   }];
}

@end