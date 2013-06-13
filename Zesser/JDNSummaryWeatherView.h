//
//  JDNSummaryWeatherView.h
//  TestStory
//
//  Created by Daniele Giove on 6/13/13.
//
//

#import <UIKit/UIKit.h>

@interface JDNSummaryWeatherView : UIView

@property (strong,nonatomic) UILabel *temperature;
@property (strong,nonatomic) UILabel *minTemperature;
@property (strong,nonatomic) UILabel *maxTemperature;
@property (strong,nonatomic) UILabel *forecast;
@property (strong,nonatomic) UILabel *wind;

@end
