//
//  JDNTestConnection.h
//  Zesser
//
//  Created by Daniele Giove on 6/7/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDNTestConnection : NSObject

-(void)checkConnectionToUrl: (NSString*)url  withCallback:(BooleanCallBack)callback;

@end
