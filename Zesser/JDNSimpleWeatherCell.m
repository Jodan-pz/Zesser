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
    [[self loadingView] stopAnimating];
    self.forecast.image = nil;
    [self.forecast setNeedsDisplay];
    self.temperature.text = nil;
}

-(UIActivityIndicatorView*) loadingView{
    if ( !_loading ){
        _loading = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0,0,32,32)];
        _loading.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        _loading.hidesWhenStopped = YES;
        _loading.tag = 73;
        if ( ![self.forecast viewWithTag:73]){
            [self.forecast addSubview:_loading];
        }
    }
    return _loading;
}

-(void)startLoadingData{
    [[self loadingView] startAnimating];
}

-(void)setupCellWithDailyData:(JDNDailyData *)dailyData{
    [[self loadingView] stopAnimating];
    if (!dailyData) return;
    self.temperature.text = [NSString stringWithFormat:@"%@°", dailyData.apparentTemperature];
    [[JDNSharedImages sharedImages] setImageView:self.forecast
                                         withUrl:[NSURL URLWithString:dailyData.forecastImage]];
    [JDNClientHelper configureTemperatureLayoutForLabel:self.temperature
                                                byValue:dailyData.apparentTemperature.integerValue];
}

@end
