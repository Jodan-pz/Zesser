//
//  JDNWeatherDataDelegate.h
//  Zesser
//
//  Created by Daniele Giove on 6/10/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JDNWeatherDataDelegate <NSObject>

-(void)weatherDataChangedForCity:(JDNCity*)city;

@end