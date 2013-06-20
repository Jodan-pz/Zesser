//
//  JDNCitySearcher.h
//  Zesser
//
//  Created by Daniele Giove on 08/06/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDNCitySearcher : NSObject

-(void)searchPlaceByText:(NSString*)textToSearch includeWorld:(BOOL)includeWorld withCompletion:(ArrayDataCallBack)completion;

@end
