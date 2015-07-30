//
//  JDNCitySearcher.m
//  Zesser
//
//  Created by Daniele Giove on 08/06/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import "JDNCitySearcher.h"
#import "XPathQuery.h"
#import "JDNCity.h"
#import "JDNWorldCitySearcher.h"

@interface JDNCitySearcher()<NSURLConnectionDataDelegate>

@property (strong,nonatomic) NSString               *receivedString;
@property (strong,nonatomic) NSMutableData          *receivedData;
@property (strong,nonatomic) ArrayDataCallBack      callback;
@property (strong,nonatomic) JDNWorldCitySearcher   *worldCitySearcher;
@property (strong,nonatomic) NSString               *placeToFind;
@property (nonatomic)        BOOL                   includeWorld;

@end

@implementation JDNCitySearcher

#define BASE_URL          @"http://www.meteoam.it/"
#define SRCH_URL BASE_URL @"/ricerca_localita/autocomplete/"

- (id)init
{
    self = [super init];
    if (self) {
        self.worldCitySearcher = [JDNWorldCitySearcher sharedWorldCitySearcher];
    }
    return self;
}

-(void)searchPlaceByText:(NSString*)textToSearch includeWorld:(BOOL)includeWorld withCompletion:(ArrayDataCallBack)completion {

    NSString *text = [textToSearch stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    
    self.callback = completion;
    self.receivedData = [[NSMutableData alloc] init];
    self.receivedString = @"";
    self.includeWorld = includeWorld;
    self.placeToFind = textToSearch;
    
    NSString *searchUrl = [SRCH_URL stringByAppendingString:text];
    
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
    if (err){
        // avoid error messages of wrong json result parsing (maybe too fast...)
        return;
    }
    
    NSMutableArray *ret =  [NSMutableArray arrayWithArray:[self collectData:parseResult]];
    
    if (self.includeWorld){
        [self.worldCitySearcher searchPlaceByText:self.placeToFind withCompletion:^(NSArray *data) {

            [ret addObjectsFromArray:data];
            
            self.callback( [ret sortedArrayUsingComparator:^NSComparisonResult(JDNCity *obj1, JDNCity *obj2) {
                return  [obj1.name compare:obj2.name];
            }]);
            
        }];
        
    }else{
        self.callback( [ret sortedArrayUsingComparator:^NSComparisonResult(JDNCity *obj1, JDNCity *obj2) {
            return  [obj1.name compare:obj2.name];
        }]);
    }
}

- (NSArray*)collectData:(NSDictionary*)jsonData {
    if (jsonData.count == 0) return nil;
    NSMutableArray *datas = [NSMutableArray array];
    NSArray *keys = jsonData.allKeys;
    for (NSUInteger i=0; i < keys.count; i++){
        JDNCity *data = [[JDNCity alloc] init];
        data.isInItaly = YES;
        data.name = [jsonData valueForKey: keys[i]];
        [datas addObject:data];
    }
    return  datas;
}

@end