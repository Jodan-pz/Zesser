//
//  JDNDailyData.m
//  Zesser
//
//  Created by Daniele Giove on 6/5/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import "JDNDailyData.h"

#define KEY_FORECAST        @"KEY_FORECAST"
#define KEY_FORECAST_IMAGE  @"KEY_FORECAST_IMAGE"
#define KEY_WIND            @"KEY_WIND"
#define KEY_WIND_IMAGE      @"KEY_WIND_IMAGE"
#define KEY_TEMP            @"KEY_TEMP"
#define KEY_PERC_RAINFALL   @"KEY_PERC_RAINFALL"
#define KEY_APPTEMP         @"KEY_APPTEMP"
#define KEY_DAY             @"KEY_DAY"
#define KEY_DAYHOUR         @"KEY_DAYHOUR"

@implementation JDNDailyData

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.forecast              forKey:KEY_FORECAST];
    [aCoder encodeObject:self.forecastImage         forKey:KEY_FORECAST_IMAGE];
    [aCoder encodeObject:self.wind                  forKey:KEY_WIND];
    [aCoder encodeObject:self.windImage             forKey:KEY_WIND_IMAGE];
    [aCoder encodeObject:self.temperature           forKey:KEY_TEMP];
    [aCoder encodeObject:self.percentageRainfall    forKey:KEY_PERC_RAINFALL];
    [aCoder encodeObject:self.apparentTemperature   forKey:KEY_APPTEMP];
    [aCoder encodeObject:self.day                   forKey:KEY_DAY];
    [aCoder encodeObject:self.hourOfDay             forKey:KEY_DAYHOUR];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self.forecast               = [aDecoder decodeObjectForKey:KEY_FORECAST];
    self.forecastImage          = [aDecoder decodeObjectForKey:KEY_FORECAST_IMAGE];
    self.wind                   = [aDecoder decodeObjectForKey:KEY_WIND];
    self.windImage              = [aDecoder decodeObjectForKey:KEY_WIND_IMAGE];
    self.temperature            = [aDecoder decodeObjectForKey:KEY_TEMP];
    self.percentageRainfall     = [aDecoder decodeObjectForKey:KEY_PERC_RAINFALL];
    self.apparentTemperature    = [aDecoder decodeObjectForKey:KEY_APPTEMP];
    self.day                    = [aDecoder decodeObjectForKey:KEY_DAY];
    self.hourOfDay              = [aDecoder decodeObjectForKey:KEY_DAYHOUR];
    return self;
}

-(BOOL)isToday{
    NSRange idx = [self.day rangeOfString:@","];
    if (idx.location == NSNotFound) return NO; // unable to evaluate
    NSInteger today = [[ self.day substringFromIndex:idx.location+1] integerValue];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:[NSDate date]];
    return [components day] == today;
}

-(void)setDay:(NSString *)day{
    NSRange pos = [day rangeOfString:@"lun,"options:NSCaseInsensitiveSearch];
    if ( pos.location != NSNotFound){
        _day = [@"Lunedì, " stringByAppendingString:[day substringFromIndex: pos.location + pos.length ]];
    }else{
        pos = [day rangeOfString:@"mar,"options:NSCaseInsensitiveSearch];
        if ( pos.location != NSNotFound){
            _day = [@"Martedì, " stringByAppendingString:[day substringFromIndex: pos.location + pos.length ]];
        }else{
            pos = [day rangeOfString:@"mer,"options:NSCaseInsensitiveSearch];
            if ( pos.location != NSNotFound){
                _day = [@"Mercoledì, " stringByAppendingString:[day substringFromIndex: pos.location + pos.length ]];
            }else{
                pos = [day rangeOfString:@"gio,"options:NSCaseInsensitiveSearch];
                if ( pos.location != NSNotFound){
                    _day = [@"Giovedì, " stringByAppendingString:[day substringFromIndex: pos.location + pos.length ]];
                }else{
                    pos = [day rangeOfString:@"ven,"options:NSCaseInsensitiveSearch];
                    if ( pos.location != NSNotFound){
                        _day = [@"Venerdì, " stringByAppendingString:[day substringFromIndex: pos.location + pos.length ]];
                    }else{
                        pos = [day rangeOfString:@"sab,"options:NSCaseInsensitiveSearch];
                        if ( pos.location != NSNotFound){
                            _day = [@"Sabato, " stringByAppendingString:[day substringFromIndex: pos.location + pos.length ]];
                        }else{
                            pos = [day rangeOfString:@"dom,"options:NSCaseInsensitiveSearch];
                            if ( pos.location != NSNotFound){
                                _day = [@"Domenica, " stringByAppendingString:[day substringFromIndex: pos.location + pos.length ]];
                            }else{
                                _day = day;
                            }
                        }
                    }
                }
            }
        }
    }
}

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