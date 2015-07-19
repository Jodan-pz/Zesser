//
//  JDNCityUrlSearcher.m
//  Zesser
//
//  Created by Daniele Giove on 06/07/15.
//  Copyright (c) 2015 Daniele Giove. All rights reserved.
//

#import "JDNCityUrlSearcher.h"

@interface JDNCityUrlSearcher()<NSURLConnectionDataDelegate>
@property (strong,nonatomic) StringDataCallBack      callback;
@end


@implementation JDNCityUrlSearcher

#define POST_URL          @"http://www.meteoam.it/node/675"

-(void)searchCityUrlByText:(NSString *)textToSearch withCompletion:(StringDataCallBack)completion{
    self.callback = completion;
    
    NSData              *postData   = [[@"ricerca_localita=" stringByAppendingString: textToSearch ] dataUsingEncoding:NSUTF8StringEncoding];
    NSString            *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL: [NSURL URLWithString: POST_URL]
                                    cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
                                    timeoutInterval: 10
                                    ];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text"             forHTTPHeaderField:@"Data-Type"];
    [request setValue:postLength          forHTTPHeaderField:@"Content-Length"];
    
    request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    request.HTTPBody = postData;

    NSURLConnection *connection = [[NSURLConnection alloc]
                                   initWithRequest:request
                                   delegate:self
                                   startImmediately:YES];
    if(!connection) {
        NSLog(@"connection failed :(");
        if ( completion ) completion( nil );
    }

}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"Search city error: %@", error.debugDescription);
    if ( self.callback ) self.callback(nil);
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
    NSString *location = [[httpResponse allHeaderFields ] valueForKey:@"Location"];
    if ( self.callback ) self.callback( location );
}

@end