//
//  JDNCity.m
//  Zesser
//
//  Created by Daniele Giove on 6/6/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import "JDNCity.h"

#define KEY_NAME   @"KEY_NAME"
#define KEY_URL    @"KEY_URL"
#define KEY_ORDER  @"KEY_ORDER"

@implementation JDNCity

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.name      forKey:KEY_NAME];
    [aCoder encodeObject:self.url       forKey:KEY_URL];
    [aCoder encodeInt   :self.order     forKey:KEY_ORDER];
    
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self.name   = [aDecoder decodeObjectForKey:KEY_NAME];
    self.url    = [aDecoder decodeObjectForKey:KEY_URL];
    self.order  = [aDecoder decodeIntForKey   :KEY_ORDER];
    return self;
}

@end 