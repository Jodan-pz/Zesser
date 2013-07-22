//
//  JDNCities.m
//  Zesser
//
//  Created by Daniele Giove on 6/6/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import "JDNCities.h"
#import "JDNCity.h"
#import "NSDictionary+LinqExtensions.h"

@interface JDNCities()

@property (strong, nonatomic) NSMutableDictionary *mcities;

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
    JDNCity *editCity = self.mcities[city.key];
    if ( editCity ){
        editCity.order = order;
    }
}

-(NSArray *)cities{
    return [[self.mcities allValues] sortedArrayUsingComparator:^NSComparisonResult(JDNCity *obj1, JDNCity *obj2) {
        return [ @(obj1.order) compare: @(obj2.order) ];
    }];
}

-(void)updateOrAddByOldCity:(JDNCity*)oldCity andNewCity:(JDNCity*)newCity{
    
    if ( [oldCity isEqualToCity:newCity]) return;
    
    if ( oldCity ) {
        [self removeCity:oldCity];
        [self.mcities setValue:newCity forKey:newCity.key];
    }else{
        JDNCity *temp = self.mcities[newCity.key];
        if ( !temp ){
            [self.mcities setValue:newCity forKey:newCity.key];
        }
    }
}

-(void)removeDynamicCities{
    JDNCity *first = self.cities[0];
    [self.mcities removeAllObjects];
    if ( first.isFixed ){
        [self.mcities setValue:first forKey:first.key];
    }
}

-(void)addCity:(JDNCity *)city {
    if ( ![self.mcities where:^BOOL(id key, JDNCity *value) {
        return [value.name isEqualToString:city.name];
    }].count) {
        city.order = ((JDNCity*)[self.cities lastObject]).order + 1;
        [self.mcities setValue:city forKey:city.key];
        [self write];
    };
}

-(void)removeCity:(JDNCity *)city{
    JDNCity *cityToRemove = self.mcities[city.key];
    if ( cityToRemove ) {
        [self.mcities removeObjectForKey:cityToRemove.key];
        [self write];
        [[NSNotificationCenter defaultCenter] postNotificationName:CITY_REMOVED_NOTIFICATION  object:cityToRemove];
    }
}

-(void)load{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    self.mcities = [NSKeyedUnarchiver unarchiveObjectWithFile:[documentsDirectory
                                                               stringByAppendingPathComponent:@"cities.dat"]];
    if ( !self.mcities ) {
        self.mcities = [NSMutableDictionary dictionary];
    }
    [self write];
}

-(void)write{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSDictionary *toWrite = [self.mcities where:^BOOL(NSString *cityName, JDNCity *item) {
        return item.order >=0;
    } ];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:toWrite];
    NSError *err;
    [data writeToFile:[documentsDirectory stringByAppendingPathComponent:@"cities.dat"]
              options:NSDataWritingFileProtectionComplete error:&err];
    if ( err ){
        NSLog(@"Error saving cities: %@", err.debugDescription);
    }
}

@end