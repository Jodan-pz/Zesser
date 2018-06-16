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
    
    if ( [JDNClientHelper stringIsNilOrEmpty:city.url]){
        if ( callback != nil ) callback(nil);
        return;
    }
    
    self.callback = callback;
    self.receivedData = [[NSMutableData alloc] init];
    self.city = city;
    
    NSURL *url = nil;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:url
                                    cachePolicy: NSURLRequestReloadIgnoringCacheData
                                    timeoutInterval: 10
                                    ];
    
    
    if ( city.isInItaly ){
        url = [NSURL URLWithString: [ITA_BASE_URL stringByAppendingString:city.url]];
    }else{
        url = [NSURL URLWithString: [WLD_BASE_URL stringByAppendingString:city.url]];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"json"             forHTTPHeaderField:@"Data-Type"];
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

-(NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse{
    return nil;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    self.receivedData.length = 0;
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.receivedData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
            dispatch_async(dispatch_get_main_queue(), ^{
                self.callback( data );
            });
        }
    });
}

-(NSArray*)collectWorldData{
    NSMutableArray *datas = [NSMutableArray arrayWithCapacity:5];
    NSError        *err;
    NSDictionary   *parseResult  = [NSJSONSerialization
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
            /*if ( iconUriFragment.length == 1 ) {
                iconUriFragment = [@"0" stringByAppendingString:iconUriFragment];
            }*/
            if ( iconNumber.intValue % 100 == 2 ){
                iconUriFragment = [iconUriFragment stringByAppendingString:@"a"];
            }
            dataMin.forecastImage = [WLD_BASE_URL
                                     stringByAppendingFormat:@"images/%@.png", iconUriFragment];
            
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

-(NSString*) formatItalyDate: (NSString*)ddMMyyyy{
    NSDateFormatter *format         = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd/MM/yyyy"];
    NSDate      *currentDate        = [format dateFromString:ddMMyyyy];
    NSDateComponents *components    = [[NSCalendar currentCalendar]
                                       components:NSCalendarUnitDay
                                       fromDate:currentDate];
    format.dateFormat=@"EEEE";
    NSString *dayString             = [[format stringFromDate:currentDate] capitalizedString];
    NSString *fmtDate               = [NSString stringWithFormat:@"%@, %li",
                                       dayString ,
                                       (long)[components day]];
    return fmtDate;
}

-(NSArray*)collectItalyDataByDate: (NSString*)date {
    NSData *pageData = self.receivedData; // ] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *datePath = [[@"//div[@id='previsioni']//div[@id='"
                           stringByAppendingString:date ]
                          stringByAppendingString:@"']"];
    /*
    NSArray *divPrevisioni = PerformHTMLXPathQuery(pageData,
                                                   @"//div[@id='previsioni']");
    */
    
    NSString *dataDate = [PerformHTMLXPathQuery(pageData,
                                                [datePath stringByAppendingString: @"//thead/tr/th[1]"]) valueForKey:@"nodeContent"] [0];

    NSString *currentDate = [self formatItalyDate:dataDate];
    
    NSArray *dataFirst = [[PerformHTMLXPathQuery(pageData,
                                                 [datePath stringByAppendingString:@"//tbody/tr"])
                           valueForKey:@"nodeChildArray"] valueForKey:@"nodeContent"];
    
    NSArray *dataSecond = [[PerformHTMLXPathQuery(pageData,
                                                  [datePath stringByAppendingString:@"//tbody/tr/td/img[not(starts-with(@class,'icona'))]"])
                            valueForKey:@"nodeAttributeArray"]
                           valueForKey:@"nodeContent"];
    
    NSArray *dataPercTemp = [PerformHTMLXPathQuery(pageData,
                                                   [datePath stringByAppendingString:@"//tbody/tr/td/span[@class='temperatura-percepita']"]) valueForKey:@"nodeContent"];
    // add dot after 'vento' + '.png' !
    // from css: sites/all/themes/meteoam/css/img-stile/vento-w.png
    NSArray *dataWindImage = [[PerformHTMLXPathQuery(pageData,
                                                     [datePath stringByAppendingString:@"//tbody/tr/td/span[starts-with(@class,'vento')]"]) valueForKey:@"nodeAttributeArray"] valueForKey:@"nodeContent"];
    
    NSArray *dataWindDesc = [[PerformHTMLXPathQuery(pageData,
                                                    [datePath stringByAppendingString:@"//tbody/tr/td/span[starts-with(@class,'vento')]/span"])
                              valueForKey:@"nodeAttributeArray"]
                             valueForKey:@"nodeContent"] ;
    
    NSArray *dataWindSpeed = [PerformHTMLXPathQuery(pageData,
                                                    [datePath stringByAppendingString:@"//tbody/tr/td/span[starts-with(@class,'vento')]/span"]) valueForKey:@"nodeContent"];
    
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:dataFirst.count];
    
    for (int i=0; i < dataFirst.count; i++) {
        JDNDailyData *italyDailyData = [[JDNDailyData alloc] init];
        italyDailyData.day = currentDate;
        italyDailyData.hourOfDay = dataFirst[i][0];
        italyDailyData.temperature = dataFirst[i][4];
        
        if (dataPercTemp.count > 0)
            italyDailyData.apparentTemperature = dataPercTemp[i];
        else
            italyDailyData.apparentTemperature = italyDailyData.temperature;

        italyDailyData.percentageRainfall =  [dataFirst[i][3] stringByReplacingOccurrencesOfString:@"%" withString:@""];
        italyDailyData.forecast = dataSecond[i][1];
        
        NSString *forecastImage = dataSecond[i][0];
        if ( [forecastImage characterAtIndex:0] == '/'){
            forecastImage = [forecastImage substringFromIndex:1]; // skip first if slash!
        }
        
        NSString *a = [NSString stringWithFormat:@"http://web.archive.org/web/20150703005656/%@", [ITA_BASE_URL stringByAppendingString:forecastImage] ];
        
        italyDailyData.forecastImage = a; //[ITA_BASE_URL stringByAppendingString:forecastImage];
        italyDailyData.wind = dataWindDesc[i][1];
        
        NSString *windImage = dataWindImage[i][0];
        if ([windImage isEqualToString:@"ventoVariabile"] || [windImage isEqualToString:@"calmaDiVento"]){
            windImage = @"";
        }else{
            NSString *windImageDirection = [windImage stringByReplacingOccurrencesOfString:@"vento"  withString:@""];
                windImage = [@"\n" stringByAppendingString:windImageDirection];
        }
        italyDailyData.windSpeed = [dataWindSpeed[i] stringByAppendingString:windImage];
        [ret addObject:italyDailyData];
    }
    
    return  ret;
}

- (NSArray*)collectData {
    NSMutableArray *datas = [NSMutableArray arrayWithCapacity:5];
    [datas addObjectsFromArray: [self collectItalyDataByDate:@"oggi"]];
    [datas addObjectsFromArray: [self collectItalyDataByDate:@"domani"]];
    [datas addObjectsFromArray: [self collectItalyDataByDate:@"tregiorni"]];
    return datas;
}

@end
