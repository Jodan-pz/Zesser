//
//  JDNCurrentWeatherView.m
//  TestStory
//
//  Created by Daniele Giove on 6/13/13.
//
//

#import "JDNCurrentWeatherView.h"

@implementation JDNCurrentWeatherView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.temperature = [[UILabel alloc] initWithFrame:CGRectMake(10, 28, 50, 32)];
        self.temperature.textAlignment = NSTextAlignmentCenter;
        self.temperature.font = [UIFont fontWithName:@"Helvetica-Bold" size:25];
        self.temperature.backgroundColor = [UIColor clearColor];
        
        self.forecastImage = [[UIImageView alloc] initWithFrame:CGRectMake(70, 28, 32, 32)];
        self.forecastImage.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.temperature];
        [self addSubview:self.forecastImage];
    }
    return self;
}

@end