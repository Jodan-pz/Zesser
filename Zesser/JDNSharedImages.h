//
//  JDNSharedImages.h
//  Zesser
//
//  Created by Daniele Giove on 6/6/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import <Foundation/Foundation.h>
@class JDNDailyData;

@interface JDNSharedImages : NSObject

-(void)setImageView:(UIImageView*)aView withUrl:(NSURL*)url;
-(void)updateImageForView:(UIImageView*)aView andImage:(UIImage*)image;
-(void)store;
-(void)retrieve;

+ (JDNSharedImages*)sharedImages;

@end