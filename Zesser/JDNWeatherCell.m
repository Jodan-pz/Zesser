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
    self.temperature.text = [NSString stringWithFormat:@"%@°", dailyData.temperature];

    [self configureTemperatureLayoutForLabel:self.apparentTemperature
                                    byValue:dailyData.apparentTemperature.integerValue];
    self.apparentTemperature.text = [NSString stringWithFormat:@"(%@°)", dailyData.apparentTemperature];
    
    [[JDNSharedImages sharedImages] setImageView:self.windImage withUrl:[NSURL URLWithString:dailyData.windImage]];
    [[JDNSharedImages sharedImages] setImageView:self.forecastImage withUrl:[NSURL URLWithString:dailyData.forecastImage]];
    self.forecast.text = dailyData.forecast;
    self.forecast.textColor = [UIColor colorWithRed:0.828 green:0.757 blue:0.941 alpha:1.000];
    self.wind.text = dailyData.wind;
}

-(void)configureTemperatureLayoutForLabel:(UILabel*)aView byValue:(NSInteger)value{
    if ( value > 38 ){
        aView.textColor = [UIColor colorWithRed:0.986 green:0.000 blue:0.029 alpha:1.000];
    }else if ( value > 32 ){
        aView.textColor = [UIColor orangeColor];
    }else if ( value > 26 ){
        aView.textColor = [UIColor yellowColor];
    }else if( value > 22 ){
        aView.textColor = [UIColor colorWithRed:0.121 green:0.776 blue:0.484 alpha:1.000];
    }else if ( value <= 0){
        aView.textColor = [UIColor cyanColor];
    }else{
        aView.textColor = [UIColor whiteColor];
    }
}

@end