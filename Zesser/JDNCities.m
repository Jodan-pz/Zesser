//
//  JDNCities.m
//  Zesser
//
//  Created by Daniele Giove on 6/6/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import "JDNCities.h"
#import "JDNCity.h"
#import "NSArray+LinqExtensions.h"

@interface JDNCities()

@property (strong, nonatomic) NSMutableArray *mcities;

@end

@implementation JDNCities

static JDNCities *sharedCities_;

+ (void)initialize{
    sharedCities_ = [[self alloc] initSingleton];
}

+ (JDNCities*)sharedCities{
    return sharedCities_;
}

- (JDNCities*)initSingleton{
    self = [super init];
    if (self) {
        [self load];
    }
    return self;
}

-(void)setOrderForCity:(JDNCity *)city order:(NSInteger)order{
    JDNCity *editCity = [[ self.mcities where:^BOOL(JDNCity *item) {
        return [item.name isEqualToString:city.name];
    } ]firstOrNil];
    if ( editCity ){
        editCity.order = order;
    }
}

-(NSArray *)cities{
    return [self.mcities sortedArrayUsingComparator:^NSComparisonResult(JDNCity *obj1, JDNCity *obj2) {
        return [ @(obj1.order) compare: @(obj2.order) ];
    }];
}

-(JDNCity*)addCity:(JDNCity*)city withOrder:(NSInteger)order{
    JDNCity *temp = [[ self.mcities where:^BOOL(JDNCity *item) {
        return [item.name isEqualToString:city.name];
    }] firstOrNil];
    
    if (!temp){
        city.order = order;
        [self.mcities addObject:city];
        [self write];
    }else{
        // update fixed city
        if (temp.order == -1){
            temp.name = city.name;
            temp.url = city.url;
        }
    }
    return temp;
}

-(void)addCity:(JDNCity *)city {
    if (![[ self.mcities where:^BOOL(JDNCity *item) {
        return [item.name isEqualToString:city.name];
    }] firstOrNil]){
        city.order = ((JDNCity*)[self.cities lastObject]).order + 1;
        [self.mcities addObject:city];
        [self write];
    };
}

-(void)removeCity:(JDNCity *)city{
    JDNCity *cityToRemove = [[ self.mcities where:^BOOL(JDNCity *item) {
        return [item.name isEqualToString:city.name];
    }] firstOrNil];
    if ( cityToRemove ) {
        [self.mcities removeObject:cityToRemove];
        [self write];
        [[NSNotificationCenter defaultCenter] postNotificationName:CITY_REMOVED_NOTIFICATION  object:cityToRemove];
    }
}

-(void)load{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    self.mcities = [NSKeyedUnarchiver unarchiveObjectWithFile:[documentsDirectory
                                                               stringByAppendingPathComponent:@"cities.dat"]];
    [self write];
}

-(void)write{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[self.mcities where:^BOOL(JDNCity *item) {
        return item.order >=0;
    } ]];
    NSError *err;
    [data writeToFile:[documentsDirectory stringByAppendingPathComponent:@"cities.dat"]
              options:NSDataWritingFileProtectionComplete error:&err];
    if ( err ){
        NSLog(@"Error saving cities: %@", err.debugDescription);
    }
}

@end