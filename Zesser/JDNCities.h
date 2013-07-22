//
//  JDNCities.h
//  Zesser
//
//  Created by Daniele Giove on 6/6/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CITY_REMOVED_NOTIFICATION @"JDN_CITY_REMOVED_NOTIFICATION"

@class JDNCity;

@interface JDNCities : NSObject

@property (strong, readonly, nonatomic) NSArray *cities;

+ (JDNCities*)sharedCities;

-(void)removeDynamicCities;
-(void)addCity:(JDNCity*)city;
-(void)updateOrAddByOldCity:(JDNCity*)oldCity andNewCity:(JDNCity*)newCity;
-(void)removeCity:(JDNCity*)city;
-(void)setOrderForCity:(JDNCity*)city order:(NSInteger)order;
-(void)load;
-(void)write;

@end
