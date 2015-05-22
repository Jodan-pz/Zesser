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
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:url
                                    cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
                                    timeoutInterval: 10
                                    ];
    
    
    if ( city.isInItaly ){
        url = [NSURL URLWithString: [ITA_BASE_URL stringByAppendingString:city.url]];
    }else{
        url = [NSURL URLWithString: [WLD_BASE_URL stringByAppendingString:city.url]];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"json"             forHTTPHeaderField:@"Data-Type"];
        request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    }
    
    [request setURL:url];
    
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
    NSArray *data = nil;
    @try{
        if ( self.city.isInItaly ){
            self.receivedString = [[NSString alloc] initWithData:self.receivedData
                                                        encoding:NSUTF8StringEncoding];
            
            if ( !self.receivedString ){
                self.receivedString = [[NSString alloc] initWithData:self.receivedData
                                                            encoding:NSASCIIStringEncoding];
            }
            
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
    
    NSMutableArray *datas = [NSMutableArray arrayWithCapacity:5];
    NSError         *err;
    NSDictionary    *parseResult  = [NSJSONSerialization
                                     JSONObjectWithData:self.receivedData
                                     options:NSJSONReadingMutableContainers
                                     error:&err];
    
    if (err){
        // avoid error messages of wrong json result parsing (maybe too fast...)
        return datas;
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    
    NSDateFormatter *dayFormat = [[NSDateFormatter alloc] init];
    [dayFormat setDateFormat:@"dd"];
    
    NSDateFormatter *dayNameFormat = [[NSDateFormatter alloc] init];
    [dayNameFormat setDateFormat:@"EEEE"];
    [dayNameFormat setLocale: [NSLocale currentLocale]];
    
    NSDictionary *forecast = [[parseResult valueForKey:@"city"] valueForKey:@"forecast"];
    @try{
        for (NSDictionary *forecastDay in [forecast valueForKey:@"forecastDay"]){
            
            JDNDailyData *dataMin = [[JDNDailyData alloc] init];
            
            NSDate *fDate = [df dateFromString: [forecastDay valueForKey:@"forecastDate"]];
            
            dataMin.day = [JDNClientHelper capitalizeFirstCharOfString: [NSString stringWithFormat:@"%@, %@",
                                                                         [dayNameFormat stringFromDate:fDate],
                                                                         [dayFormat stringFromDate:fDate]]];
            
            dataMin.hourOfDay    = @"01:00";
            dataMin.temperature  = dataMin.apparentTemperature = [forecastDay valueForKey:@"minTemp"];
            dataMin.forecast     = [forecastDay valueForKey:@"weather"];
            NSNumber *iconNumber = [forecastDay valueForKey:@"weatherIcon"];
            
            NSString *iconUriFragment = iconNumber.stringValue;
            iconUriFragment = [iconUriFragment substringWithRange:NSMakeRange(0, iconUriFragment.length-2)];
            if ( iconUriFragment.length == 1 ) {
             iconUriFragment = [@"0" stringByAppendingString:iconUriFragment];
            }
            
            dataMin.forecastImage = [WLD_BASE_URL
                                     stringByAppendingFormat:@"images/wxicon/pic%@.png", iconUriFragment];
            
            JDNDailyData *dataMax = [[JDNDailyData alloc] init];
            dataMax.day             = dataMin.day;
            dataMax.hourOfDay       = @"13:00";
            dataMax.temperature     = dataMax.apparentTemperature = [forecastDay valueForKey:@"maxTemp"];
            dataMax.forecast        = dataMin.forecast;
            dataMax.forecastImage   = dataMin.forecastImage;
            
            [datas addObject:dataMin];
            [datas addObject:dataMax];
        }
        
    }@catch (NSException * e) {
        NSLog(@"collectWorldData Exception: %@", e);
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
    
    NSArray *rainAndTemperatures = [PerformHTMLXPathQuery([finalXml dataUsingEncoding:NSUTF8StringEncoding],
                                                   @"//table/tr/td[@class='previsioniRow']/strong" )
                             valueForKey:@"nodeContent"];
    
    
    NSMutableArray *temperatures = [NSMutableArray array];
    NSMutableArray *rain = [NSMutableArray array];
    
    for (int i=0; i<rainAndTemperatures.count; i++) {
        if ( i%2 != 0 ){
            [temperatures addObject: [rainAndTemperatures objectAtIndex:i ]];
        }else{
            [rain addObject: [rainAndTemperatures objectAtIndex:i ]];
        }
    }
    
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
        data.percentageRainfall = rain[i];
    }
    return datas;
}

@end