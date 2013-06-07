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

-(NSArray *)cities{
    return self.mcities;
}

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

-(void)addCity:(JDNCity *)city{
    if (![[ self.mcities where:^BOOL(JDNCity *item) {
        return [item.name isEqualToString:city.name];
    }] firstOrNil]){
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
    }
}

-(void)load{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    self.mcities = [NSKeyedUnarchiver unarchiveObjectWithFile:[documentsDirectory stringByAppendingPathComponent:@"cities.plist"]];
    
    if ( !self.mcities){
        self.mcities = [NSMutableArray array];
        JDNCity *city = [[JDNCity alloc] init];
        city.name = @"Casa";
        city.url =@"3841/POZZO%20D'ADDA";
        [((NSMutableArray*)self.mcities) addObject:city];
        
        JDNCity *city2 = [[JDNCity alloc] init];
        city2.name = @"Muggia";
        city2.url = @"8250/MUGGIA";
        [((NSMutableArray*)self.mcities) addObject:city2];
    }
    
    [self write];
}

-(void)write{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.mcities];
    NSError *err;
    [data writeToFile:[documentsDirectory stringByAppendingPathComponent:@"cities.plist"]
              options:NSDataWritingFileProtectionComplete error:&err];
    if ( err ){
        NSLog(@"Error saving cities: %@", err.debugDescription);
    }
}

@end