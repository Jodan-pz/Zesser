//
//  JDNCities.m
//  Zesser
//
//  Created by Daniele Giove on 6/6/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import "JDNCities.h"
#import "JDNCity.h"

@interface JDNCities()
@property (strong, nonatomic) NSMutableArray *cities;
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
    {
        self = [super init];
        if (self) {
            [self load];
        }
        return self;
    }
}

-(void)load{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    self.cities = [NSKeyedUnarchiver unarchiveObjectWithFile:[documentsDirectory stringByAppendingPathComponent:@"cities.plist"]];
   
    if ( !self.cities){
        self.cities = [NSMutableArray array];
        JDNCity *city = [JDNCity new];
        city.name = @"Pozzo";
        city.url =@"3841/POZZO%20D'ADDA";
        [((NSMutableArray*)self.cities) addObject:city];
        JDNCity *city2 = [JDNCity new];
        city2.name = @"Milano";
        city2.url =@"87/MILANO";
        [((NSMutableArray*)self.cities) addObject:city2];
    }
    [self write];
}

-(void)write{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.cities];
    NSError *err;
    [data writeToFile:[documentsDirectory stringByAppendingPathComponent:@"cities.plist"]
              options:NSDataWritingFileProtectionComplete error:&err];
    if ( err ){
        NSLog(@"Error saving cities: %@", err.debugDescription);
    }
}

@end