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
@property (strong,nonatomic) GetDataCallBack    callback;

@end

@implementation JDNWeatherFetcher

#define BASE_URL          @"http://www.meteoam.it/"
#define DATA_URL BASE_URL @"?q=ta/previsione/%@"

-(void)isAvailable:(BooleanCallBack)callback {
    JDNTestConnection *testConnection = [[JDNTestConnection alloc] init];
    [testConnection checkConnectionToUrl:@"http://www.aadsadasxazx.dsa" withCallback:callback];
}

-(void)fetchDailyDataForCity:(NSString *)cityName withCompletion:(GetDataCallBack)callback{
    self.callback = callback;
    self.receivedData = [[NSMutableData alloc] init];
    self.receivedString = @"";
        
    NSURLRequest *request = [[NSURLRequest alloc]
 							 initWithURL: [NSURL URLWithString: [NSString stringWithFormat:DATA_URL, cityName]]
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
    
    /*NSArray *titles = [PerformXMLXPathQuery([finalXml
                                             dataUsingEncoding:NSUTF8StringEncoding],
                                            @"/table/tr[1]/td/strong" )
                       valueForKeyPath:@"nodeContent"];
    */
    NSArray *daysAndHours = [[PerformXMLXPathQuery([finalXml dataUsingEncoding:NSUTF8StringEncoding],
                                                   @"/table/tr/td[@class='previsioniRow']" )
                              valueForKeyPath:@"nodeContent"] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *evaluatedObject, NSDictionary *bindings) {
        return evaluatedObject != nil &&  [evaluatedObject class] != [NSNull class] ;
    }]] ;
    
    NSArray *temperatures = [PerformXMLXPathQuery([finalXml dataUsingEncoding:NSUTF8StringEncoding],
                                                  @"/table/tr/td[@class='previsioniRow']/strong" )
                             valueForKeyPath:@"nodeContent"];
    
    NSArray *forecastAndWind = [[PerformXMLXPathQuery([finalXml dataUsingEncoding:NSUTF8StringEncoding],
                                                      @"/table/tr/td[@class='previsioniRow']/img" )
                                 valueForKeyPath:@"nodeAttributeArray"] valueForKey:@"nodeContent"];
    
    NSArray *tempprec = [PerformXMLXPathQuery([finalXml dataUsingEncoding:NSUTF8StringEncoding],
                                              @"/table/tr/td[@class='previsioniRow']/div" )
                         valueForKeyPath:@"nodeContent"];
    
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
        data.apparentTemperature = tempprec[i];
    }

    return datas;
}

@end