//
//  JDNSimpleWeatherCell.h
//  Zesser
//
//  Created by Daniele Giove on 6/7/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDNSimpleWeatherCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *cityName;
@property (weak, nonatomic) IBOutlet UILabel *temperature;
@property (weak, nonatomic) IBOutlet UIImageView *forecast;

-(void)clear;
-(void)startLoadingData;
-(void)setupCellWithDailyData:(JDNDailyData *)dailyData;

@end
