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
#define KEY_ISITA  @"KEY_ISITA"

@implementation JDNCity

- (id)init
{
    self = [super init];
    if (self) {
        self.order = 0;
    }
    return self;
}

-(NSString*)key{
    return [self.name stringByAppendingFormat:@"_%ld" , (long)self.order];
}

-(NSUInteger)hash{
    NSUInteger result = 1;
    NSUInteger prime = 31;
    result = prime * result + [self.name hash];
    result = prime * result + [self.url hash];
    result = prime * result + self.order;
    result = prime * result + self.isInItaly?YESPRIME:NOPRIME;
    return result;
}

-(BOOL)isEqual:(id)object{
    if ( !object || ![object isKindOfClass:[self class]]) return NO;
    return  [self isEqualToCity:(JDNCity*)object];
}

-(BOOL)isEqualToCity:(JDNCity*)other{
    if (other == self)
        return YES;
    BOOL ret = [self.name isEqualToString:other.name] &&
    [self.url isEqualToString:other.url] &&
    self.order == other.order &&
    self.isInItaly == other.isInItaly;
    return ret;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%@ - %@ - %ld - (%@)", self.name, self.url, (long)self.order, self.isInItaly?@"ITA":@"WLD"];
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.name      forKey:KEY_NAME];
    [aCoder encodeObject:self.url       forKey:KEY_URL];
    [aCoder encodeInt   :self.order     forKey:KEY_ORDER];
    [aCoder encodeBool  :self.isInItaly forKey:KEY_ISITA];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self.name       = [aDecoder decodeObjectForKey:KEY_NAME];
    self.url        = [aDecoder decodeObjectForKey:KEY_URL];
    self.order      = [aDecoder decodeIntForKey   :KEY_ORDER];
    self.isInItaly  = [aDecoder decodeBoolForKey  :KEY_ISITA];
    return self;
}

@end