//
//  JDNWorldCitySearcher.h
//  Zesser
//
//  Created by Daniele Giove on 08/06/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDNWorldCitySearcher : NSObject

-(void)searchPlaceByText:(NSString*)textToSearch withCompletion:(ArrayDataCallBack)completion;

+ (JDNWorldCitySearcher*)sharedWorldCitySearcher;

@end
