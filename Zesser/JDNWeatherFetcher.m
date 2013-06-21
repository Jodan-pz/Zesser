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
#import "JDNCity.h"

@interface JDNWeatherFetcher()<NSURLConnectionDataDelegate>

@property (strong,nonatomic) NSString           *receivedString;
@property (strong,nonatomic) NSMutableData      *receivedData;
@property (strong,nonatomic) ArrayDataCallBack  callback;
@property (nonatomic)        JDNCity            *city;

@end

@implementation JDNWeatherFetcher

#define ITA_BASE_URL          @"http://www.meteoam.it/"
#define WLD_BASE_URL          @"http://wwis.meteoam.it/"

-(void)isAvailable:(BooleanCallBack)callback {
    JDNTestConnection *testConnection = [[JDNTestConnection alloc] init];
    [testConnection checkConnectionToUrl:ITA_BASE_URL
                            withCallback:^(BOOL result) {
                                callback(result);
                            }];
}


-(void)fetchDailyDataForCity:(JDNCity *)city withCompletion:(ArrayDataCallBack)callback{
    self.callback = callback;
    self.receivedData = [[NSMutableData alloc] init];
    self.receivedString = @"";
    self.city = city;
    
    NSURL *url = nil;
    
    if ( city.isItaly ){
        url = [NSURL URLWithString: [ITA_BASE_URL stringByAppendingString:city.url]];
    }else{
        url = [NSURL URLWithString: [WLD_BASE_URL stringByAppendingString:city.url]];
    }
    
    NSURLRequest *request = [[NSURLRequest alloc]
 							 initWithURL:url
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
    
    NSArray *data = nil;
    if ( self.city.isItaly ){
        data = [self collectData];
    }else{
        data = [self collectWorldData];
    }
    self.callback( data );
}

-(NSArray*)collectWorldData{
    NSRange rangeFlag = [self.receivedString rangeOfString:@"wxforecast"];
    if (rangeFlag.location == NSNotFound) return nil;
    NSString *tmp = [self.receivedString substringFromIndex:rangeFlag.location];
    
    NSRange table = [tmp rangeOfString:@"<table"];
    if (table.location == NSNotFound) return nil;
    tmp = [ tmp substringFromIndex:table.location];
    
    NSRange rangeFlag2 = [tmp rangeOfString:@"wxforecast" options:NSBackwardsSearch];
    if (rangeFlag2.location == NSNotFound) return nil;
    tmp = [tmp substringToIndex:rangeFlag2.location];
    
    NSRange tableEnd = [tmp rangeOfString:@"</table>" options:NSBackwardsSearch];
    if (tableEnd.location == NSNotFound) return nil;
    tmp = [tmp substringToIndex:tableEnd.location + tableEnd.length];

    NSString *finalXml = [JDNClientHelper unescapeString:tmp];

    NSArray *days = [ PerformHTMLXPathQuery([finalXml dataUsingEncoding:NSUTF8StringEncoding],@"//table/tr[position()>2]" ) valueForKeyPath:@"nodeChildArray.nodeContent"];
    NSArray *forecast = [[  PerformHTMLXPathQuery([finalXml dataUsingEncoding:NSUTF8StringEncoding],@"//table/tr[position()>2]/td" )
                          valueForKeyPath:@"nodeChildArray.nodeChildArray.nodeChildArray.nodeChildArray.nodeContent"] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *evaluatedObject, NSDictionary *bindings) {
        return evaluatedObject != nil &&  [evaluatedObject class] != [NSNull class] ;
    }]];

    
    NSArray *minTemps = [ PerformHTMLXPathQuery([finalXml dataUsingEncoding:NSUTF8StringEncoding],@"//table/tr[position()>2]" ) valueForKeyPath:@"nodeChildArray.nodeContent"];
    
    NSMutableArray *datas = [NSMutableArray arrayWithCapacity:5];
    
    NSUInteger foreIndex = 4;
    for (NSUInteger i = 0; i < days.count; i++) {
        NSRange sep = [days[i][0] rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
        NSString *day = [ days[i][0] substringToIndex:sep.location];
        NSRange posStart = [days[i][0] rangeOfString:@"("];
        NSRange posEnd = [days[i][0] rangeOfString:@")"];
        NSString *nameOfDay = [[days[i][0] substringFromIndex:posStart.location + posStart.length] substringToIndex:posEnd.location - (posStart.location + posStart.length)];
        day = [[nameOfDay stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
               stringByAppendingFormat:@", %@", day];
        
        JDNDailyData *dataMin = [[JDNDailyData alloc] init];
        dataMin.day = day;
        dataMin.hourOfDay = @"01:00";
        dataMin.forecast = forecast[foreIndex][0][0][0][0];
        [datas addObject:dataMin];

        JDNDailyData *dataMax = [[JDNDailyData alloc] init];
        dataMax.day = day;
        dataMax.hourOfDay = @"13:00";
        dataMax.forecast = forecast[foreIndex][0][0][0][0];
        
        foreIndex += 5;
        
        [datas addObject:dataMax];
    }
    
    return datas;
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
        data.forecastImage = [ITA_BASE_URL stringByAppendingString:forecastAndWind[i][0]];
        data.wind = forecastAndWind[i+1][1];
        data.windImage = [ITA_BASE_URL stringByAppendingString: forecastAndWind[i+1][0]];
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