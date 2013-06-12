//
//  JDNSimpleWeatherCell.m
//  Zesser
//
//  Created by Daniele Giove on 6/7/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import "JDNSimpleWeatherCell.h"
#import "JDNDailyData.h"


@implementation JDNSimpleWeatherCell{
    UIActivityIndicatorView *_loading;
}

-(void)clear{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( _loading){
            [_loading stopAnimating];
        }
        self.forecast.image = nil;
        [self.forecast setNeedsDisplay];
        self.temperature.text = nil;
    });
}

-(void)startLoadingData{
    dispatch_async(dispatch_get_main_queue(), ^{
        _loading = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0,0,32,32)];
        _loading.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        _loading.hidesWhenStopped = YES;
        [self.forecast addSubview:_loading];
        [_loading startAnimating];
    });
}

-(void)setupCellWithDailyData:(JDNDailyData *)dailyData{
    
    if (!dailyData) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_loading stopAnimating];
        self.temperature.text = [NSString stringWithFormat:@"%@°", dailyData.apparentTemperature];
        [[JDNSharedImages sharedImages] setImageView:self.forecast
                                             withUrl:[NSURL URLWithString:dailyData.forecastImage]];
        [JDNClientHelper configureTemperatureLayoutForLabel:self.temperature
                                                    byValue:dailyData.apparentTemperature.integerValue];
    });
}

@end
