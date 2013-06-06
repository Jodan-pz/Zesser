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
    [self configureTemperatureLayoutForView:self.temperature
                                    byValue:dailyData.temperature.integerValue];
    
    self.temperature.text = dailyData.temperature;

    [self configureTemperatureLayoutForView:self.apparentTemperature
                                    byValue:dailyData.apparentTemperature.integerValue];
    self.apparentTemperature.text = dailyData.apparentTemperature;
    
    [[JDNSharedImages sharedImages] setImageView:self.windImage withUrl:[NSURL URLWithString:dailyData.windImage]];
    [[JDNSharedImages sharedImages] setImageView:self.forecastImage withUrl:[NSURL URLWithString:dailyData.forecastImage]];
    self.forecast.text = dailyData.forecast;
    self.wind.text = dailyData.wind;
}

-(void)configureTemperatureLayoutForView:(UIView*)aView byValue:(NSInteger)value{
    if ( value > 32 ){
        aView.backgroundColor = [UIColor redColor];
    }else if( value > 22 ){
        aView.backgroundColor = [UIColor yellowColor];
    }else if ( value <= 0){
        aView.backgroundColor = [UIColor cyanColor];
    }else{
        aView.backgroundColor = [UIColor whiteColor];
    }
}

@end