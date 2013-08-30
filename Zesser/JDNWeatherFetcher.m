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
    
    if ( city.isInItaly ){
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
                                                encoding:NSUTF8StringEncoding];
    
    if ( !self.receivedString ){
        self.receivedString = [[NSString alloc] initWithData:self.receivedData
                                                    encoding:NSASCIIStringEncoding];
    }
    
    NSArray *data = nil;
    @try{
        if ( self.city.isInItaly ){
            data = [self collectData];
        }else{
            data = [self collectWorldData];
        }
        
    }@catch (NSException *ne) {
        [JDNClientHelper showError:ne.description];
    }@finally{
        self.callback( data );
    }
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
    NSArray *forecast  = [PerformHTMLXPathQuery([finalXml dataUsingEncoding:NSUTF8StringEncoding],@"//table/tr[position()>2]/td" ) valueForKeyPath:@"nodeChildArray.nodeChildArray.nodeAttributeArray.nodeContent"];

    NSArray *temps = [ PerformHTMLXPathQuery([finalXml dataUsingEncoding:NSUTF8StringEncoding],@"//table/tr[position()>2]/td" ) valueForKeyPath:@"nodeChildArray.nodeChildArray"];
    
    NSMutableArray *datas = [NSMutableArray arrayWithCapacity:5];
    
    NSUInteger foreIndex = 3;
    NSUInteger tempIndex = 1;
    
    for (NSUInteger i = 0; i < days.count; i++) {
        
        NSString *fullDay = days[i][0];
        NSString *day;
        
        NSRange sep = [fullDay rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]];
        if ( sep.location != NSNotFound ){
            day = [fullDay substringToIndex:sep.location];
        }else{
            sep = [fullDay rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
            day = [fullDay substringToIndex:sep.location];
        }
        NSRange posStart = [fullDay rangeOfString:@"("];
        NSRange posEnd = [fullDay rangeOfString:@")"];
        NSString *nameOfDay = [[fullDay substringFromIndex:posStart.location + posStart.length] substringToIndex:posEnd.location - (posStart.location + posStart.length)];
        day = [[nameOfDay stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
               stringByAppendingFormat:@", %@", day];
        
        JDNDailyData *dataMin = [[JDNDailyData alloc] init];
        dataMin.day = day;
        dataMin.hourOfDay = @"01:00";
        dataMin.temperature = dataMin.apparentTemperature = [temps[tempIndex][0][0] valueForKey:@"nodeContent"];
        dataMin.forecast = forecast[foreIndex][0][0][1];
        NSString *foreImage = forecast[foreIndex][0][0][0];
        NSRange fixUrl = [foreImage rangeOfString:@"/"];
        foreImage = [foreImage substringFromIndex:fixUrl.location + fixUrl.length];
        dataMin.forecastImage = [WLD_BASE_URL stringByAppendingString:foreImage];
        [datas addObject:dataMin];

        JDNDailyData *dataMax = [[JDNDailyData alloc] init];
        dataMax.day = dataMin.day;
        dataMax.hourOfDay = @"13:00";
        dataMax.forecast = dataMin.forecast;
        dataMax.forecastImage = dataMin.forecastImage;
        dataMax.temperature = dataMax.apparentTemperature = [temps[tempIndex+1][0][0] valueForKey:@"nodeContent"];
        
        foreIndex += 5;
        tempIndex += 5;
        
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
    finalXml = [finalXml stringByReplacingOccurrencesOfString:@"<BR>" withString:@" "];
    
    NSArray *daysHoursWind = [[PerformHTMLXPathQuery([finalXml dataUsingEncoding:NSUTF8StringEncoding],
                                                   @"//table/tr/td[@class='previsioniRow']" )
                              valueForKey:@"nodeContent"] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *evaluatedObject, NSDictionary *bindings) {
        return evaluatedObject != nil &&  [evaluatedObject class] != [NSNull class] ;
    }]] ;
    
    NSArray *temperatures = [PerformHTMLXPathQuery([finalXml dataUsingEncoding:NSUTF8StringEncoding],
                                                  @"//table/tr/td[@class='previsioniRow']/strong" )
                             valueForKey:@"nodeContent"];
    
    NSArray *forecastAndWindImage = [[PerformHTMLXPathQuery([finalXml dataUsingEncoding:NSUTF8StringEncoding],
                                                      @"//table/tr/td[@class='previsioniRow']/img" )
                                 valueForKey:@"nodeAttributeArray"] valueForKey:@"nodeContent"];
    
    NSArray *appTemp = [PerformHTMLXPathQuery([finalXml dataUsingEncoding:NSUTF8StringEncoding],
                                              @"//table/tr/td[@class='previsioniRow']/div" )
                        valueForKey:@"nodeContent"];
    
    NSMutableArray *datas = [NSMutableArray arrayWithCapacity:5];
    
    for (NSUInteger i = 0; i < daysHoursWind.count; i+=3) {
        JDNDailyData *data = [[JDNDailyData alloc] init];
        data.day = daysHoursWind[i];
        data.hourOfDay = daysHoursWind[i+1];
        data.wind = daysHoursWind[i+2];
        [datas addObject:data];
    }
    
    for (NSUInteger a=0, i=0; i< forecastAndWindImage.count; a++, i+=2){
        JDNDailyData *data = datas[a];
        data.forecast = forecastAndWindImage[i][1];
        data.forecastImage = [ITA_BASE_URL stringByAppendingString:forecastAndWindImage[i][0]];
        data.windImage = [ITA_BASE_URL stringByAppendingString: forecastAndWindImage[i+1][0]];
    }
    
    for (NSUInteger i=0; i < temperatures.count; i++) {
        JDNDailyData *data = datas[i];
        data.temperature = temperatures[i];
        data.apparentTemperature = appTemp[i];
    }
    return datas;
}

@end