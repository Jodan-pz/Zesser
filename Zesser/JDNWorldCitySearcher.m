//
//  JDNWorldCitySearcher.m
//  Zesser
//
//  Created by Daniele Giove on 08/06/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import "JDNWorldCitySearcher.h"
#import "XPathQuery.h"
#import "JDNCity.h"

@interface JDNWorldCitySearcher()<NSURLConnectionDataDelegate>

@property (strong,nonatomic) NSString               *receivedString;
@property (strong,nonatomic) NSMutableData          *receivedData;
@property (strong,nonatomic) ArrayDataCallBack      callback;
@property (strong,nonatomic) NSMutableArray         *cachedCities;
@property (strong,nonatomic) NSString               *placeToSearch;

@end

@implementation JDNWorldCitySearcher

#define BASE_URL          @"http://wwis.meteoam.it"

static JDNWorldCitySearcher *sharedWorldCitySearcher_;

+ (void)initialize{
    sharedWorldCitySearcher_ = [[self alloc] initSingleton];
}

+ (JDNWorldCitySearcher*)sharedWorldCitySearcher{
    return sharedWorldCitySearcher_;
}

- (JDNWorldCitySearcher*)initSingleton{
    self = [super init];
    if ( self ){
        self.cachedCities = [NSMutableArray array];
        // prefill cities
        [self collectCities];
    }
    return self;
}

-(void)collectCities{
    [self fetchAllCitiesWithCompletion:^(NSArray *data) {
        [self.cachedCities addObjectsFromArray:data];
    }];
}

-(void)searchPlaceByText:(NSString*)textToSearch withCompletion:(ArrayDataCallBack)completion {
    
    if ( self.cachedCities.count == 0){
        [self fetchAllCitiesWithCompletion:^(NSArray *data) {
            [self.cachedCities addObjectsFromArray:data];
            
            NSArray *worldFiltered = [self.cachedCities filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(JDNCity *city, NSDictionary *bindings) {
                return [city.name rangeOfString:textToSearch options:NSCaseInsensitiveSearch].location == 0;
            }]];
            completion(worldFiltered);
            
        }];
        
    }else{
        
        NSArray *worldFiltered = [self.cachedCities filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(JDNCity *city, NSDictionary *bindings) {
            return [city.name rangeOfString:textToSearch options:NSCaseInsensitiveSearch].location == 0;
        }]];
        completion(worldFiltered);
    }
    
    
}

-(void)fetchAllCitiesWithCompletion:(ArrayDataCallBack)callback{
    self.callback = callback;
    self.receivedData = [[NSMutableData alloc] init];
    self.receivedString = @"";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
 							 initWithURL: [NSURL URLWithString: BASE_URL]
 							 cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
 							 timeoutInterval: 10
 							 ];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:@"text"             forHTTPHeaderField:@"Data-Type"];
 
    request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    
    NSURLConnection *connection = [[NSURLConnection alloc]
 								   initWithRequest:request
 								   delegate:self
 								   startImmediately:YES];
 	if(!connection) {
 		NSLog(@"connection failed :(");
        if ( callback ) callback( nil );
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
    self.receivedString = [[NSString alloc] initWithData:self.receivedData
                                                encoding:NSUTF8StringEncoding];
    
    [self.cachedCities removeAllObjects];
    self.callback([self collectData]);
}

- (NSArray*)collectData {
    NSMutableArray *datas = [NSMutableArray array];
    NSMutableString *xmlData = [[NSMutableString alloc] initWithString:@"<html>"];
    NSRange form = [self.receivedString rangeOfString:@"<form name=\"cityform\">"];
    [xmlData appendString:[self.receivedString substringFromIndex:form.location ]];
    NSRange formEnd = [xmlData rangeOfString:@"</form>"];
    NSString *finalXml = [xmlData substringToIndex:formEnd.location + formEnd.length ];
    finalXml =  [finalXml stringByAppendingString:@"</html>"];
    
    NSArray *names = [ PerformHTMLXPathQuery( [finalXml dataUsingEncoding:4],@"//form/select/option" )  valueForKey:@"nodeContent"];
    NSArray *urls = [[ PerformHTMLXPathQuery( [finalXml dataUsingEncoding:4],@"//form/select/option" )  valueForKey:@"nodeAttributeArray"] valueForKey:@"nodeContent"];
    
    if ( urls.count == 0 ){
        return nil;
    }
    
    for (NSUInteger i=0; i < urls.count; i++) {
        
        NSRange isCity = [names[i] rangeOfString:@"("];
        if ( isCity.location == NSNotFound) continue;
        
        JDNCity *data = [[JDNCity alloc] init];
        NSString *url = [urls[i]lastObject];
        data.name = names[i];
        data.url = url;
        data.isInItaly = NO;
        [datas addObject:data];
    }
    return datas;
}

@end