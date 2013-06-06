//
//  JDNCities.h
//  Zesser
//
//  Created by Daniele Giove on 6/6/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDNCities : NSObject

@property (strong, readonly, nonatomic) NSArray *cities;

+ (JDNCities*)sharedCities;

-(void)load;
-(void)write;

@end
