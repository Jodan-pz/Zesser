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

-(BOOL)isItaly{
    return  [self.country caseInsensitiveCompare:@"Italia" ] == NSOrderedSame;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"Loc: %@ - SubArea: %@ - (%@)",
            self.locality,
            self.subAreaLocality,
            self.country];
}

-(JDNPlace *)initWithPlacemark:(CLPlacemark *)placemark{
    if ( self = [super init]){
        self.locality        = placemark.locality;
        self.subAreaLocality = placemark.subAdministrativeArea;
        self.country         = placemark.country;
        
    }
    return self;
}

+(JDNPlace *)placeWithPlacemark:(CLPlacemark *)placemark{
    return [[JDNPlace alloc] initWithPlacemark:placemark];
}

@end