//
//  JDNFetchWeather.m
//  Zesser
//
//  Created by Daniele Giove on 6/5/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import "JDNFetchWeather.h"
#import "JDNDailyData.h"
#import "XPathQuery.h"

@interface JDNFetchWeather()<NSURLConnectionDataDelegate>

@property (strong,nonatomic) NSString      *receivedString;
@property (strong,nonatomic) NSMutableData *receivedData;
@property (strong,nonatomic) GetDataCallBack callback;

@end

@implementation JDNFetchWeather

-(void)fetchDailyDataForCity:(NSString *)cityName withCompletion:(GetDataCallBack)callback{
    self.callback = callback;
    self.receivedData = [NSMutableData new];
    self.receivedString = @"";
    
    NSString *baseUrl = @"http://www.meteoam.it/?q=ta/previsione/%@";
    
    NSURLRequest *request = [[NSURLRequest alloc]
 							 initWithURL: [NSURL URLWithString: [NSString stringWithFormat:baseUrl, cityName]]
 							 cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
 							 timeoutInterval: 10
 							 ];
    
    NSURLConnection *connection = [[NSURLConnection alloc]
 								   initWithRequest:request
 								   delegate:self
 								   startImmediately:YES];
 	if(!connection) {
 		NSLog(@"connection failed :(");
 	} else {
 		NSLog(@"connection succeeded  :)");
 		
 	}
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    self.receivedData.length = 0;
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.receivedData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    self.receivedString = [[NSString alloc] initWithData:self.receivedData
                                           encoding:NSASCIIStringEncoding];

    NSMutableString *xmlData = [[NSMutableString alloc] initWithString:@"<table id=\""];
    
    NSRange tab = [self.receivedString rangeOfString:@"previsioniOverlTable"];
    [xmlData appendString:[self.receivedString substringFromIndex:tab.location ]];
    
    NSRange tabEnd = [xmlData rangeOfString:@"</table>"];
    NSString *finalXml = [xmlData substringToIndex:tabEnd.location + tabEnd.length ];
    
    NSArray *titles = [PerformXMLXPathQuery([finalXml
                                             dataUsingEncoding:NSUTF8StringEncoding],
                                             @"/table/tr[1]/td/strong" )
                       valueForKeyPath:@"nodeContent"];
    
    NSArray *x = [PerformXMLXPathQuery([finalXml dataUsingEncoding:NSUTF8StringEncoding],
                                 @"/table/tr/td[@class='previsioniRow']" )
                  valueForKeyPath:@"nodeContent"];
    
    NSLog(@"%@", titles);
    
    
    
    NSMutableArray *datas = [NSMutableArray arrayWithCapacity:5];
    JDNDailyData *data = [[JDNDailyData alloc] init];
    data.name = @"test";
    
    [datas addObject:data];

    self.callback(datas);
}

@end