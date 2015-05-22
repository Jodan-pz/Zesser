//
//  JDNSummaryWeatherView.m
//  TestStory
//
//  Created by Daniele Giove on 6/13/13.
//
//

#import "JDNSummaryWeatherView.h"

@implementation JDNSummaryWeatherView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        self.forecast = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, frame.size.width, 19)];
        self.forecast.font = [UIFont systemFontOfSize:9.0];
        self.forecast.textColor = [UIColor colorWithRed:0.878 green:0.673 blue:0.926 alpha:1.000];
        
        self.wind = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, frame.size.width, 25)];
        self.wind.font = [UIFont systemFontOfSize:9.0];
        self.wind.textColor = [UIColor colorWithRed:0.645 green:0.901 blue:0.916 alpha:1.000];
        self.wind.lineBreakMode = NSLineBreakByTruncatingTail;
        self.wind.numberOfLines = 2;
        
        self.temperature = [[UILabel alloc] initWithFrame:CGRectMake(2, 50, 36, 31)];
        self.temperature.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
        self.temperature.textColor = [UIColor whiteColor];
        self.temperature.textAlignment = NSTextAlignmentCenter;
        
        UILabel *lblMin = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, 28, 16)];
        lblMin.textAlignment = NSTextAlignmentCenter;
        lblMin.text = @"Min";
        lblMin.textColor = [UIColor whiteColor];
        lblMin.font = [UIFont fontWithName:@"Helvetica" size:10];
        
        self.minTemperature = [[UILabel alloc] initWithFrame:CGRectMake(50, 65, 28, 16)];
        self.minTemperature.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
        self.minTemperature.textAlignment = NSTextAlignmentCenter;

        UILabel *lblMax = [[UILabel alloc] initWithFrame:CGRectMake(80, 50, 28, 16)];
        lblMax.textAlignment = NSTextAlignmentCenter;
        lblMax.text = @"Max";
        lblMax.textColor = [UIColor whiteColor];
        lblMax.font = [UIFont fontWithName:@"Helvetica" size:10];
        
        self.maxTemperature = [[UILabel alloc] initWithFrame:CGRectMake(80, 65, 28, 16)];
        self.maxTemperature.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
        self.maxTemperature.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:self.forecast];
        [self addSubview:self.wind];
        
        [self addSubview:self.temperature];
        [self addSubview:lblMin];
        [self addSubview:self.minTemperature];
        [self addSubview:lblMax];
        [self addSubview:self.maxTemperature];
        
        lblMin.backgroundColor =
        lblMax.backgroundColor =
        self.temperature.backgroundColor =
        self.forecast.backgroundColor =
        self.wind.backgroundColor =
        self.minTemperature.backgroundColor =
        self.maxTemperature.backgroundColor = [UIColor clearColor];
    }
    return self;
}
@end