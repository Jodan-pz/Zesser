//
//  JDNCityUrlSearcher.h
//  Zesser
//
//  Created by Daniele Giove on 06/07/15.
//  Copyright (c) 2015 Daniele Giove. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDNItalyCityUrlSearcher : NSObject

-(void)searchCityUrlByText:(NSString*)textToSearch withCompletion:(StringDataCallBack)completion;

@end