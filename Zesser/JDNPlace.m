//
//  JDNPlace.m
//  Zesser
//
//  Created by Daniele Giove on 16/06/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import "JDNPlace.h"
#import <CoreLocation/CoreLocation.h>

@implementation JDNPlace

-(NSString *)description{
    return [NSString stringWithFormat:@"Loc: %@ - SubArea: %@",
            self.locality,
            self.subAreaLocality];
}

-(JDNPlace *)initWithPlacemark:(CLPlacemark *)placemark{
    if ( self = [super init]){
        self.locality = placemark.locality;
        self.subAreaLocality = placemark.subAdministrativeArea;
    }
    return self;
}

+(JDNPlace *)placeWithPlacemark:(CLPlacemark *)placemark{
    return [[JDNPlace alloc] initWithPlacemark:placemark];
}

@end