//
//  JDNPlace.h
//  Zesser
//
//  Created by Daniele Giove on 16/06/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLPlacemark;

@interface JDNPlace : NSObject

@property (strong,nonatomic) NSString *locality;
@property (strong,nonatomic) NSString *subAreaLocality;

-(JDNPlace *)initWithPlacemark:(CLPlacemark *)placemark;
+(JDNPlace*)placeWithPlacemark:(CLPlacemark*)placemark;

@end