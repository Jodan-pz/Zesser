//
//  JDNFindMyPlace.h
//  Zesser
//
//  Created by Daniele Giove on 6/11/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class JDNPlace;

@protocol JDNFindMyPlaceDelegate <NSObject>

-(void)findMyPlaceDidFoundCurrentLocation:(JDNPlace*)place;

@end

@interface JDNFindMyPlace : NSObject

@property (weak,nonatomic) id<JDNFindMyPlaceDelegate> delegate;

-(void)startSearchingCurrentLocation;

@end