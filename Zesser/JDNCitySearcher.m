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
#define SRCH_URL BASE_URL @"/sites/all/block/ricerca_localita/request.php"

- (id)init
{
    self = [super init];
    if (self) {
        self.worldCitySearcher = [JDNWorldCitySearcher sharedWorldCitySearcher];
    }
    return self;
}

-(void)searchPlaceByText:(NSString*)textToSearch includeWorld:(BOOL)includeWorld withCompletion:(ArrayDataCallBack)completion {

    NSMutableString *temp = [[NSMutableString alloc] initWithString:textToSearch];
    [temp replaceOccurrencesOfString:@"'" withString:@"&#039;" options:NSLiteralSearch range:NSMakeRange(0, [textToSearch length])];
    [temp replaceOccurrencesOfString:@" " withString:@"%20" options:NSLiteralSearch range:NSMakeRange(0, [textToSearch length])];
    
    NSString *text = [temp copy];
    
    self.callback = completion;
    self.receivedData = [[NSMutableData alloc] init];
    self.receivedString = @"";
    self.includeWorld = includeWorld;
    self.placeToFind = textToSearch;
    
    NSData              *postData   = [[@"param=" stringByAppendingString: text ] dataUsingEncoding:NSUTF8StringEncoding];
    NSString            *postLength = [NSString stringWithFormat:@"%d", [postData length]];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
 							 initWithURL: [NSURL URLWithString: SRCH_URL]
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
    self.receivedData.length = 0;
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.receivedData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    self.receivedString = [[NSString alloc] initWithData:self.receivedData
                                                encoding:NSUTF8StringEncoding];

    NSMutableArray *ret =  [NSMutableArray arrayWithArray:[self collectData]];
    
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

- (NSArray*)collectData {
    NSMutableArray *datas = [NSMutableArray array];
    NSMutableString *xmlData = [[NSMutableString alloc] initWithString:@"<root>"];
    [xmlData appendString:self.receivedString];
    [JDNClientHelper unescapeMutableString:xmlData];

    // fix single quote error for href tag
    xmlData = [[[xmlData stringByReplacingOccurrencesOfString:@"href='" withString:@"href=\""] stringByReplacingOccurrencesOfString:@"'>" withString:@"\">" ] mutableCopy];
    
    [xmlData appendString:@"</root>"];
    
    NSArray *urls = [[PerformXMLXPathQuery([xmlData dataUsingEncoding:NSUTF8StringEncoding],
                                           @"/root/a[@class='link-localita']" )
                      valueForKey:@"nodeAttributeArray"]
                     valueForKey:@"nodeContent"];
    
    if ( urls.count == 0 ){
        return nil;
    }
    
    NSArray *names = [PerformXMLXPathQuery([xmlData dataUsingEncoding:NSUTF8StringEncoding],@"/root/a/div[@class='localita']" ) valueForKey:@"nodeContent"];
    
    for (NSUInteger i=0; i < urls.count; i++) {
        JDNCity *data = [[JDNCity alloc] init];
        NSString *fullURL = [urls[i]lastObject];
        NSRange range = [fullURL rangeOfString:@"/" options:NSBackwardsSearch];
        NSString *url = [fullURL substringToIndex:range.location];
        data.isItaly = YES;
        data.name = names[i];
        data.url = url;
        [datas addObject:data];
    }
    return  datas; 
}

@end