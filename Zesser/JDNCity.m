//
//  JDNCity.m
//  Zesser
//
//  Created by Daniele Giove on 6/6/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import "JDNCity.h"

#define CACHE_NAME   @"CACHE_NAME"
#define CACHE_URL    @"CACHE_URL"
#define CACHE_ORDER  @"CACHE_ORDER"

@implementation JDNCity

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.name      forKey:CACHE_NAME];
    [aCoder encodeObject:self.url       forKey:CACHE_URL];
    [aCoder encodeInt   :self.order     forKey:CACHE_ORDER];
    
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self.name   = [aDecoder decodeObjectForKey:CACHE_NAME];
    self.url    = [aDecoder decodeObjectForKey:CACHE_URL];
    self.order  = [aDecoder decodeIntForKey   :CACHE_ORDER];
    return self;
}

@end 