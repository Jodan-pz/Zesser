//
//  JDNDailyData.h
//  Zesser
//
//  Created by Daniele Giove on 6/5/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDNDailyData : NSObject<NSCoding>

@property (strong,nonatomic)            NSString *forecast;
@property (strong,nonatomic)            NSString *forecastImage;
@property (strong,nonatomic)            NSString *wind;
@property (strong,nonatomic)            NSString *windImage;
@property (strong,nonatomic)            NSString *windSpeed;
@property (strong,nonatomic)            NSString *temperature;
@property (strong,nonatomic)            NSString *apparentTemperature;
@property (strong,nonatomic)            NSString *percentageRainfall;
@property (strong,nonatomic)            NSString *day;
@property (strong,nonatomic)            NSString *hourOfDay;
@property (strong,readonly,nonatomic)   NSString *shortDescription;

-(BOOL)isToday;

@end