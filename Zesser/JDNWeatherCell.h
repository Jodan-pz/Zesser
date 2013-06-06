//
//  JDNWeatherCell.h
//  Zesser
//
//  Created by Daniele Giove on 6/6/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JDNDailyData;

@interface JDNWeatherCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *hourOfDay;
@property (weak, nonatomic) IBOutlet UILabel *temperature;
@property (weak, nonatomic) IBOutlet UILabel *apparentTemperature;
@property (weak, nonatomic) IBOutlet UIImageView *wimdImage;
@property (weak, nonatomic) IBOutlet UIImageView *forecastImage;
@property (weak, nonatomic) IBOutlet UILabel *summary;

-(void)setupCellWithDailyData:(JDNDailyData*)dailyData;

@end
