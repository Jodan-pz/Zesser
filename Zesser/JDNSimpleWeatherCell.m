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

@interface JDNSimpleWeatherCell()

@property (strong,nonatomic) JDNCurrentWeatherView *curWeatherView;
@property (strong,nonatomic) JDNSummaryWeatherView *sumWeatherView;
@property (strong,nonatomic) UIActivityIndicatorView *loadingView;

@end

@implementation JDNSimpleWeatherCell;

-(void)configureCell {
    self.backgroundColor = [UIColor redColor];
    if (_curWeatherView) return;
    
    [self.scrollView addSubview:self.curWeatherView];
    [self.scrollView addSubview:self.sumWeatherView];
    
    CGFloat viewWidth = self.scrollView.frame.size.width;
    CGFloat viewHeight = self.scrollView.frame.size.height;
    self.scrollView.contentSize = CGSizeMake(viewWidth*2 ,viewHeight);
    self.scrollView.contentOffset = CGPointMake(0, 0);
}

-(void)clear {
    [self configureCell];
    
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

-(void)setupCellWithDailyData:(NSArray*)dailyData{
    [[self loadingView] stopAnimating];
    if ( !dailyData || !dailyData.count ) return;
    
    JDNDailyData *nowData = [dailyData firstOrNil];
    
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
    
    NSInteger minTemp = [[dailyData valueForKeyPath:@"@min.apparentTemperature"] integerValue];
    NSInteger maxTemp = [[dailyData valueForKeyPath:@"@max.apparentTemperature"] integerValue];
    
    self.sumWeatherView.minTemperature.text = [NSString stringWithFormat:@"%ld°", (long)minTemp];
    self.sumWeatherView.maxTemperature.text = [NSString stringWithFormat:@"%ld°", (long)maxTemp];
    [JDNClientHelper configureTemperatureLayoutForLabel:self.sumWeatherView.minTemperature
                                                byValue:minTemp];
    [JDNClientHelper configureTemperatureLayoutForLabel:self.sumWeatherView.maxTemperature
                                                byValue:maxTemp];
    [UIView animateWithDuration:1 animations:^{
        self.sumWeatherView.alpha = 1;
    }];
}

@end