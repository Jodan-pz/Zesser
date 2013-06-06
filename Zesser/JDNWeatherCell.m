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
    self.wimdImage
}

-(void)configureTemperatureLayoutForView:(UIView*)aView byValue:(NSInteger)value{
    if( value > 22 ){
        aView.backgroundColor = [UIColor yellowColor];
    }else if ( value <= 0){
        aView.backgroundColor = [UIColor cyanColor];
    }else{
        aView.backgroundColor = [UIColor blackColor];
    }
}

@end