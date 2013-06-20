//
//  JDNFetchWeather.h
//  Zesser
//
//  Created by Daniele Giove on 6/5/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JDNDailyData, JDNCity;

@interface JDNWeatherFetcher : NSObject

-(void)isAvailable:(BooleanCallBack)callback;
-(void)fetchDailyDataForCity:(JDNCity *)city withCompletion:(ArrayDataCallBack)callback;

@end