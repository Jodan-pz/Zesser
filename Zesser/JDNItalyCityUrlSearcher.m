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
@property (strong,nonatomic) NSString               *originalSearch;
@end


@implementation JDNItalyCityUrlSearcher

#define SRCH_URL          @"https://www.bing.com/search?q="

-(void)searchCityUrlByText:(NSString *)textToSearch withCompletion:(StringDataCallBack)completion{
    if ( !completion ) return;
    
    self.originalSearch = textToSearch;
    self.callback = completion;
    self.receivedData = [[NSMutableData alloc] init];
    
    NSString *fullSearchUrl = [SRCH_URL stringByAppendingFormat:@"ammeteo.it %@ /ta/previsione/",textToSearch];
    NSString *escapedUrl = [fullSearchUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL: [NSURL URLWithString: escapedUrl]
                                    cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
                                    timeoutInterval: 10
                                    ];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:@"text/html" forHTTPHeaderField:@"Accept"];
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

- (NSArray*)searchIn: (NSString*)source containingText: (NSString *)text {
    NSMutableArray *ret = [NSMutableArray array];
    
    // search all containing href="www.meteoam.it/ta/previsione"
    NSRange idxStart;
    
    while ( (idxStart = [source rangeOfString:@"http://www.meteoam.it/ta/previsione/"]).location != NSNotFound  ){
        NSRange idxEnd = [[source substringFromIndex:idxStart.location] rangeOfString:@"\""];
        if ( idxEnd.location != NSNotFound){
            NSString *found = [source substringWithRange:
                               NSMakeRange(idxStart.location,idxEnd.location)];
            [ret addObject: found];
            
            source = [source substringFromIndex: idxStart.location + idxEnd.location + 1];
        }else{
            NSLog(@"Error closing match");
            break;            
        }
    }
    NSString *cleanSearch = self.originalSearch;
    
    NSRange toRemoveStart = [cleanSearch rangeOfString:@"("];
    if ( toRemoveStart.location != NSNotFound){
        cleanSearch = [cleanSearch substringToIndex:toRemoveStart.location-1];
    }
    
    cleanSearch = [[[cleanSearch stringByReplacingOccurrencesOfString:@" " withString:@"_"] stringByReplacingOccurrencesOfString:@"'" withString:@"_"]
                             stringByReplacingOccurrencesOfString:@"__" withString:@"_"];

    cleanSearch = [cleanSearch stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [ret filterUsingPredicate:
     [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject,
                                           NSDictionary<NSString *,id> * _Nullable bindings)
      {return [[evaluatedObject lowercaseString] hasSuffix: [cleanSearch lowercaseString] ];}
      ]];
    
    return ret;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *resultHtml = [[NSString  alloc]
                            initWithData: self.receivedData
                            encoding:NSUTF8StringEncoding ];
    NSArray *founds = [self searchIn:resultHtml containingText:self.originalSearch];
    if ( founds.count ) {
        NSString *url = [founds firstObject];
        NSRange idx = [url rangeOfString:@"/ta"];
        if ( idx.location != NSNotFound){
            url = [url substringFromIndex:idx.location +1];
        }
        self.callback( url );
    }else{
        self.callback( nil );
    }
}
@end
