//
//  JDNDailyData.m
//  Zesser
//
//  Created by Daniele Giove on 6/5/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import "JDNDailyData.h"

@implementation JDNDailyData

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