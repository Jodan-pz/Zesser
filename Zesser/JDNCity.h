//
//  JDNCity.h
//  Zesser
//
//  Created by Daniele Giove on 6/6/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDNCity : NSObject<NSCoding>

@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSString *url;
@property (nonatomic)        NSInteger order;
@property (nonatomic)        BOOL     isInItaly;

-(void)setFixed;
-(BOOL)isFixed;
-(NSString*)key;
-(BOOL)isEqualToCity:(JDNCity*)other;

@end