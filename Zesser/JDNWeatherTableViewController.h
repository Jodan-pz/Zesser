//
//  JDNAMMeteoTableViewController.h
//  Zesser
//
//  Created by Daniele Giove on 6/5/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JDNCity;

@interface JDNWeatherTableViewController : UITableViewController

@property (strong,nonatomic) JDNCity *city;
@property (strong,nonatomic) NSArray *currentDailyData;

@end
