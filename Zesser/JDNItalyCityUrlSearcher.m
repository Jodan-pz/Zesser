//
//  JDNCityUrlSearcher.m
//  Zesser
//
//  Created by Daniele Giove on 06/07/15.
//  Copyright (c) 2015 Daniele Giove. All rights reserved.
//

#import "JDNItalyCityUrlSearcher.h"

@interface JDNItalyCityUrlSearcher()<NSURLConnectionDataDelegate>
@property (strong,nonatomic) NSMutableData          *receivedData;
@property (strong,nonatomic) StringDataCallBack      callback;
@end


@implementation JDNItalyCityUrlSearcher

#define SRCH_URL          @"http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q="

-(void)searchCityUrlByText:(NSString *)textToSearch withCompletion:(StringDataCallBack)completion{
    if ( !completion ) return;
    
    self.callback = completion;
    
    NSString *text = [textToSearch stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    self.callback = completion;
    self.receivedData = [[NSMutableData alloc] init];
    
    NSString *searchUrl = [SRCH_URL stringByAppendingFormat:@"ammeteo.it%%20%@",text];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL: [NSURL URLWithString: searchUrl]
                                    cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
                                    timeoutInterval: 10
                                    ];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"json"             forHTTPHeaderField:@"Data-Type"];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    
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
    self.receivedData.length = 0;
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.receivedData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSError         *err;
    NSDictionary    *parseResult  = [NSJSONSerialization
                                     JSONObjectWithData:self.receivedData
                                     options:NSJSONReadingMutableContainers
                                     error:&err];
    
    NSArray *urls = [parseResult[@"responseData"][@"results"] valueForKey:@"url"];
    NSArray *found = [urls filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject rangeOfString:@"www.meteoam.it/ta/previsione/"].location != NSNotFound;
    }]];
    if ( found.count ) {
        NSString *purl = [found firstObject];
        NSRange idx = [purl rangeOfString:@"/ta"];
        if ( idx.location != NSNotFound){
            purl = [purl substringFromIndex:idx.location +1];
        }
        self.callback( purl );
    }else{
        self.callback( nil );
    }
    
}
@end