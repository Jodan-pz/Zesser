//
//  JDNFindMyPlace.m
//  Zesser
//
//  Created by Daniele Giove on 6/11/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import "JDNFindMyPlace.h"
#import <CoreLocation/CoreLocation.h>
#import "JDNPlace.h"

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
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    }
    return _locationManager;
}

-(void)startSearchingCurrentLocation{
    if ( self.delegate ) {
        if ( ! [CLLocationManager locationServicesEnabled]  ||
            ([CLLocationManager authorizationStatus] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways ) ) {
            [self.delegate findMyPlaceDidFoundCurrentLocation:nil];
            return;
        }
        
        [self.locationManager requestAlwaysAuthorization];
        
        self.decoded = NO;
        
        [self performSelector:@selector(searchComplete) withObject:nil afterDelay:10];
        [self.locationManager startUpdatingLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [self.locationManager stopUpdatingLocation];
    self.decoded = NO;
    [self.delegate findMyPlaceDidFoundCurrentLocation:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    /* Save the new location to an instance variable */
    self.lastUpdatedLocation = [locations lastObject];
    /* Refuse updates more than a minute old */
    if (fabs([self.lastUpdatedLocation.timestamp timeIntervalSinceNow]) > 60.0) {
        return;
    }
    
    /* If it's accurate enough, cancel the timer */
    if (self.lastUpdatedLocation.horizontalAccuracy < 1000) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        /* And fire it manually instead */
        [self searchComplete];
    }
}


-(void)searchComplete {
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
                       CLPlacemark *placemark = placemarks[0];
                       JDNPlace *place = [JDNPlace placeWithPlacemark:placemark];
                       
                       NSString *loc = placemark.locality;
                       // fix just home!
                       if ( [placemark.postalCode isEqualToString:@"20060"] && [placemark.locality isEqualToString:@"Bettola"] ){
                           loc = @"Pozzo D'Adda";
                       }
                       place.locality = loc;
                       NSLog(@"Place: (%@)", place);
                       [self.delegate findMyPlaceDidFoundCurrentLocation:place];
                   }];
}

@end
