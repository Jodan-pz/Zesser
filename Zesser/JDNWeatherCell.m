//
//  JDNWeatherCell.m
//  Zesser
//
//  Created by Daniele Giove on 6/6/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import "JDNWeatherCell.h"
#import "JDNDailyData.h"

@implementation JDNWeatherCell

-(void)setupCellWithDailyData:(JDNDailyData *)dailyData{

    if (!dailyData) return;
    
    self.hourOfDay.text = dailyData.hourOfDay;
    if (dailyData.temperature.length != 0){
        self.temperature.text = [NSString stringWithFormat:@"%@°", dailyData.temperature];
    }else{
        self.temperature.text = @"-";
    }
    if (dailyData.apparentTemperature.length != 0){
        [JDNClientHelper configureTemperatureLayoutForLabel:self.apparentTemperature
                                                    byValue:dailyData.apparentTemperature.integerValue];
        self.apparentTemperature.text = [NSString stringWithFormat:@"(%@°)", dailyData.apparentTemperature];
    }else{
        self.apparentTemperature.text = @"-";
    }
    
    [[JDNSharedImages sharedImages] setImageView:self.windImage withUrl:[NSURL URLWithString:dailyData.windImage]];
    [[JDNSharedImages sharedImages] setImageView:self.forecastImage withUrl:[NSURL URLWithString:dailyData.forecastImage]];
    self.forecast.text = dailyData.forecast;
    self.forecast.textColor = [UIColor colorWithRed:0.828 green:0.757 blue:0.941 alpha:1.000];
    self.wind.text = dailyData.wind;
}

@end