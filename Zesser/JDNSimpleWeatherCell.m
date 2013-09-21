//
//  JDNSimpleWeatherCell.m
//  Zesser
//
//  Created by Daniele Giove on 6/7/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import "JDNSimpleWeatherCell.h"
#import "JDNDailyData.h"
#import "JDNCurrentWeatherView.h"
#import "JDNSummaryWeatherView.h"
#import "NSArray+LinqExtensions.h"
#import "JDNCity.h"

@interface JDNSimpleWeatherCell()

@property (strong,nonatomic) JDNCurrentWeatherView *curWeatherView;
@property (strong,nonatomic) JDNSummaryWeatherView *sumWeatherView;
@property (strong,nonatomic) UIActivityIndicatorView *loadingView;

@end

@implementation JDNSimpleWeatherCell;

-(void)configureScrollView {
    if (_curWeatherView) return;

    self.backgroundColor = [UIColor clearColor];
    
    [self.scrollView addSubview:self.curWeatherView];
    [self.scrollView addSubview:self.sumWeatherView];
    
    CGFloat viewWidth = self.scrollView.frame.size.width;
    CGFloat viewHeight = self.scrollView.frame.size.height;
    self.scrollView.contentSize = CGSizeMake(viewWidth*2 ,viewHeight);
    self.scrollView.contentOffset = CGPointMake(0, 0);
}

-(void)prepareForCity:(JDNCity*)city{
    
    self.scrollView.contentOffset = CGPointMake(0, 0);
    
    if (!city.isInItaly){
        self.scrollView.scrollEnabled = NO;
    }else{
        self.scrollView.scrollEnabled = YES;
    }
    
    [self configureScrollView];
    
    [[self loadingView] stopAnimating];
    
    // current
    self.curWeatherView.temperature.text = nil;
    self.curWeatherView.forecastImage.image = nil;
    [self.curWeatherView.forecastImage setNeedsDisplay];
    // summary
    self.sumWeatherView.alpha = 0;
    self.sumWeatherView.forecast.text = nil;
    self.sumWeatherView.wind.text = nil;
    self.sumWeatherView.temperature.text = nil;
    self.sumWeatherView.minTemperature.text = nil;
    self.sumWeatherView.alpha = 0;
}

-(JDNSummaryWeatherView *)sumWeatherView{
    CGFloat viewWidth = self.scrollView.frame.size.width;
    CGFloat viewHeight = self.scrollView.frame.size.height;
    if ( !_sumWeatherView){
        _sumWeatherView = [[JDNSummaryWeatherView alloc] initWithFrame:CGRectMake(viewWidth, 0, viewWidth, viewHeight)];
        _sumWeatherView.backgroundColor = [UIColor clearColor];
    }
    return _sumWeatherView;
}

-(JDNCurrentWeatherView *)curWeatherView{
    CGFloat viewWidth = self.scrollView.frame.size.width;
    CGFloat viewHeight = self.scrollView.frame.size.height;
    if (!_curWeatherView ){
        _curWeatherView = [[JDNCurrentWeatherView alloc]initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
        _curWeatherView.backgroundColor = [UIColor clearColor];
    }
    return _curWeatherView;
}

-(UIActivityIndicatorView*) loadingView {
    if ( !_loadingView ){
        _loadingView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0,0,32,32)];
        _loadingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        _loadingView.hidesWhenStopped = YES;
        _loadingView.tag = 73;
        if ( ![self.curWeatherView.forecastImage viewWithTag:73] ) {
            [self.curWeatherView.forecastImage addSubview:_loadingView];
        }
    }
    return _loadingView;
}

-(void)startLoadingData{
    [[self loadingView] startAnimating];
}

-(void)setupCellForCity:(JDNCity*)city withDailyData:(NSArray*)dailyData{
    [[self loadingView] stopAnimating];
    if ( !dailyData || !dailyData.count ) return;
    
    JDNDailyData *nowData = nil;
    
    if ( city.isInItaly ){
       nowData = [dailyData firstOrNil];
    }else{
        NSUInteger idx = [dailyData indexOfObjectPassingTest:^BOOL(JDNDailyData *dailyData, NSUInteger idx, BOOL *stop) {
            if ( [dailyData isToday] && [dailyData.hourOfDay isEqualToString:@"13:00"] ){
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        if ( idx == NSNotFound) return;
        nowData = dailyData[idx];
    }

    // current view
    self.curWeatherView.temperature.text = [NSString stringWithFormat:@"%@°", nowData.apparentTemperature];
    [[JDNSharedImages sharedImages] setImageView:self.curWeatherView.forecastImage
                                         withUrl:[NSURL URLWithString:nowData.forecastImage]];
    [JDNClientHelper configureTemperatureLayoutForLabel:self.curWeatherView.temperature
                                                byValue:nowData.apparentTemperature.integerValue];
    
    // summary view
    self.sumWeatherView.forecast.text    = nowData.forecast;
    self.sumWeatherView.wind.text        = nowData.wind;
    self.sumWeatherView.temperature.text = [NSString stringWithFormat:@"%@°", nowData.temperature];
    
    NSNumber *minTemp = [dailyData valueForKeyPath:@"@min.apparentTemperature.integerValue"];
    NSNumber *maxTemp = [dailyData valueForKeyPath:@"@max.apparentTemperature.integerValue"];
    
    self.sumWeatherView.minTemperature.text = [NSString stringWithFormat:@"%@°", minTemp];
    self.sumWeatherView.maxTemperature.text = [NSString stringWithFormat:@"%@°", maxTemp];
    [JDNClientHelper configureTemperatureLayoutForLabel:self.sumWeatherView.minTemperature
                                                byValue:minTemp.integerValue];
    [JDNClientHelper configureTemperatureLayoutForLabel:self.sumWeatherView.maxTemperature
                                                byValue:maxTemp.integerValue];
    [UIView animateWithDuration:1 animations:^{
        self.sumWeatherView.alpha = 1;
    }];
}

@end