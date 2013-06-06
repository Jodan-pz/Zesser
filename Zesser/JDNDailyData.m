//
//  JDNDailyData.m
//  Zesser
//
//  Created by Daniele Giove on 6/5/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import "JDNDailyData.h"

@implementation JDNDailyData

-(NSString *)description
{
    return [NSString stringWithFormat:@"Day: %@ at %@ - Temp: %@  - App. Temp: %@ - Forecast: %@ - Wind: %@",
            self.day,
            self.hourOfDay,
            self.temperature,
            self.apparentTemperature,
            self.forecast,
            self.wind];
}

-(NSString *)shortDescription{
    return [NSString stringWithFormat:@"Day: %@ at %@ - Temp: %@ ",
            self.day,
            self.hourOfDay,
            self.temperature];
}

@end