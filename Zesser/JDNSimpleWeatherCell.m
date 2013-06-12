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
    BOOL _addLoadingView;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if ( self = [super initWithCoder:aDecoder]){
        _loading = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0,0,32,32)];
        _loading.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        _loading.hidesWhenStopped = YES;
        _addLoadingView = YES;
    }
    return self;
}

-(void)clear{
    [_loading stopAnimating];
    self.forecast.image = nil;
    [self.forecast setNeedsDisplay];
    self.temperature.text = nil;
}

-(void)startLoadingData{
    if ( _addLoadingView ){
        [self.forecast addSubview:_loading];
        _addLoadingView = NO;
    }
    [_loading startAnimating];
}

-(void)setupCellWithDailyData:(JDNDailyData *)dailyData{
    [_loading stopAnimating];
    if (!dailyData) return;
    self.temperature.text = [NSString stringWithFormat:@"%@°", dailyData.apparentTemperature];
    [[JDNSharedImages sharedImages] setImageView:self.forecast
                                         withUrl:[NSURL URLWithString:dailyData.forecastImage]];
    [JDNClientHelper configureTemperatureLayoutForLabel:self.temperature
                                                byValue:dailyData.apparentTemperature.integerValue];
}

@end
