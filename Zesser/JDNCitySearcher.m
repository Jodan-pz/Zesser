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

@interface JDNCitySearcher()<NSURLConnectionDataDelegate>

@property (strong,nonatomic) NSString           *receivedString;
@property (strong,nonatomic) NSMutableData      *receivedData;
@property (strong,nonatomic) ArrayDataCallBack  callback;

@end

@implementation JDNCitySearcher

#define BASE_URL          @"http://www.meteoam.it/"
#define SRCH_URL BASE_URL @"/sites/all/block/ricerca_localita/request.php"

/*

 localita_path: "/sites/all/block/ricerca_localita"

 param: [textToSearch]
 
 $.ajax(
 {
 type: "POST",
 url: localita_path+'/request.php',
 data: "param="+param,
 dataType: "text",
 async:true,
 });
 
 */

-(NSArray*)searchPlaceByText:(NSString*)textToSearch{
    [self internalSearchCitiesLikeText:textToSearch withCompletion:^(NSArray *data) {
        // end
        NSLog(@"%@", data);
    }];
    return nil;
}

-(void)internalSearchCitiesLikeText:(NSString *)text withCompletion:(ArrayDataCallBack)callback{
    self.callback = callback;
    self.receivedData = [[NSMutableData alloc] init];
    self.receivedString = @"";
    
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
    self.callback( [self collectData] );
}

- (NSArray*)collectData {
    NSMutableArray *datas = [NSMutableArray array];
    NSMutableString *xmlData = [[NSMutableString alloc] initWithString:@"<root>"];
    [xmlData appendString:self.receivedString];
    [JDNClientHelper unescapeMutableString:xmlData];
    [xmlData appendString:@"</root>"];
    
    NSArray *urls = [[PerformXMLXPathQuery(
                                           [xmlData dataUsingEncoding:4],
                                           @"/root/a[@class='link-localita']" )
                      valueForKey:@"nodeAttributeArray"]
                     valueForKey:@"nodeContent"];
    
    for (NSUInteger i=0; i < urls.count; i++) {
        JDNCity *data = [[JDNCity alloc] init];
        NSString *url = [urls[i]lastObject];
        NSRange pos = [url rangeOfString:@"/" options:NSBackwardsSearch];
        if ( pos.location != NSNotFound){
            data.name = [url substringFromIndex:pos.location + pos.length];
        }else
            data.name = @"NonName";
        data.url = url;
        [datas addObject:data];
    }
    return datas;
}

@end