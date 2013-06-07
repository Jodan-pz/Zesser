//
//  JDNFetchWeather.h
//  Zesser
//
//  Created by Daniele Giove on 6/5/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import <Foundation/Foundation.h>
@class JDNDailyData;

@interface JDNWeatherFetcher : NSObject

-(void)isAvailable:(BooleanCallBack)callback;
-(void)fetchDailyDataForCity:(NSString *)cityName withCompletion:(GetDataCallBack)callback;

@end
