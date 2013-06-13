//
//  JDNFetchWeather.m
//  Zesser
//
//  Created by Daniele Giove on 6/5/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import "JDNWeatherFetcher.h"
#import "JDNDailyData.h"
#import "XPathQuery.h"
#import "JDNTestConnection.h"

@interface JDNWeatherFetcher()<NSURLConnectionDataDelegate>

@property (strong,nonatomic) NSString           *receivedString;
@property (strong,nonatomic) NSMutableData      *receivedData;
@property (strong,nonatomic) ArrayDataCallBack  callback;
@property (nonatomic)        BOOL               fetchNow;

@end

@implementation JDNWeatherFetcher

#define BASE_URL          @"http://www.meteoam.it/"

-(void)isAvailable:(BooleanCallBack)callback {
    JDNTestConnection *testConnection = [[JDNTestConnection alloc] init];
    [testConnection checkConnectionToUrl:BASE_URL
                            withCallback:^(BOOL result) {
                                callback(result);
                            }];
}


-(void)fetchDailyDataForCity:(NSString *)cityUrl withCompletion:(ArrayDataCallBack)callback{
    self.callback = callback;
    self.receivedData = [[NSMutableData alloc] init];
    self.receivedString = @"";
    
    NSURLRequest *request = [[NSURLRequest alloc]
 							 initWithURL: [NSURL URLWithString: [BASE_URL stringByAppendingString:cityUrl]]
 							 cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
 							 timeoutInterval: 10
 							 ];
    
    NSURLConnection *connection = [[NSURLConnection alloc]
 								   initWithRequest:request
 								   delegate:self
 								   startImmediately:YES];
 	if(!connection) {
 		NSLog(@"connection failed :(");
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
    self.callback( [self collectData] );
}

- (NSArray*)collectData {
    NSMutableString *xmlData = [[NSMutableString alloc] initWithString:@"<table id=\""];
    NSRange tab = [self.receivedString rangeOfString:@"previsioniOverlTable"];
    [xmlData appendString:[self.receivedString substringFromIndex:tab.location ]];
    NSRange tabEnd = [xmlData rangeOfString:@"</table>"];

    NSString *finalXml = [xmlData substringToIndex:tabEnd.location + tabEnd.length ];
    finalXml = [JDNClientHelper unescapeString:finalXml];
    // fix bad table column headers in source
    finalXml = [finalXml stringByReplacingOccurrencesOfString:@"</th>" withString:@"</td>"];
    
    NSArray *daysAndHours = [[PerformXMLXPathQuery([finalXml dataUsingEncoding:NSUTF8StringEncoding],
                                                   @"/table/tr/td[@class='previsioniRow']" )
                              valueForKey:@"nodeContent"] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *evaluatedObject, NSDictionary *bindings) {
        return evaluatedObject != nil &&  [evaluatedObject class] != [NSNull class] ;
    }]] ;
    
    NSArray *temperatures = [PerformXMLXPathQuery([finalXml dataUsingEncoding:NSUTF8StringEncoding],
                                                  @"/table/tr/td[@class='previsioniRow']/strong" )
                             valueForKey:@"nodeContent"];
    
    NSArray *forecastAndWind = [[PerformXMLXPathQuery([finalXml dataUsingEncoding:NSUTF8StringEncoding],
                                                      @"/table/tr/td[@class='previsioniRow']/img" )
                                 valueForKey:@"nodeAttributeArray"] valueForKey:@"nodeContent"];
    
    NSArray *appTemp = [PerformXMLXPathQuery([finalXml dataUsingEncoding:NSUTF8StringEncoding],
                                              @"/table/tr/td[@class='previsioniRow']/div" )
                        valueForKey:@"nodeContent"];
    
    NSMutableArray *datas = [NSMutableArray arrayWithCapacity:5];
    
    for (NSUInteger i = 0; i < daysAndHours.count; i+=2) {
        JDNDailyData *data = [[JDNDailyData alloc] init];
        data.day = daysAndHours[i];
        data.hourOfDay = daysAndHours[i+1];
        data.forecast = forecastAndWind[i][1];
        data.forecastImage = [BASE_URL stringByAppendingString:forecastAndWind[i][0]];
        data.wind = forecastAndWind[i+1][1];
        data.windImage = [BASE_URL stringByAppendingString: forecastAndWind[i+1][0]];
        [datas addObject:data];
    }
    
    for (NSUInteger i=0; i < temperatures.count; i++) {
        JDNDailyData *data = datas[i];
        data.temperature = temperatures[i];
        data.apparentTemperature = appTemp[i];
    }
    return datas;
}

@end