//
//  JDNTestConnection.m
//  Zesser
//
//  Created by Daniele Giove on 6/7/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import "JDNTestConnection.h"

@interface JDNTestConnection()<NSURLConnectionDataDelegate>

@property (strong,nonatomic) BooleanCallBack callback;

@end

@implementation JDNTestConnection

-(void)checkConnectionToUrl: (NSString*)url  withCallback:(BooleanCallBack)callback{
    if ( !callback ) return;
    
    self.callback = callback;
    NSURLRequest *request = [[NSURLRequest alloc]
 							 initWithURL: [NSURL URLWithString: url]
 							 cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
 							 timeoutInterval: 5
 							 ];
    
    NSURLConnection *connection = [[NSURLConnection alloc]
 								   initWithRequest:request
 								   delegate:self
 								   startImmediately:YES];
    
    if(!connection) {
        callback(NO);
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    self.callback(NO);
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    self.callback(YES);
    [connection cancel];
    connection = nil;
}

@end