//
//  JDNAddCityDelegate.h
//  Zesser
//
//  Created by Daniele Giove on 6/10/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import <Foundation/Foundation.h>
@class JDNCity;

@protocol JDNAddCityDelegate <NSObject>

-(void)didAddedNewCity:(JDNCity*)newCity
                sender:(UIViewController*)sender;

@end
