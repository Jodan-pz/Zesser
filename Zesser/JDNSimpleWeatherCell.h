//
//  JDNSimpleWeatherCell.h
//  Zesser
//
//  Created by Daniele Giove on 6/7/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JDNCity;

@interface JDNSimpleWeatherCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *cityName;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

-(void)prepareForCity:(JDNCity*)city;
-(void)startLoadingData;
-(void)setupCellForCity:(JDNCity*)city withDailyData:(NSArray*)dailyData;

@end