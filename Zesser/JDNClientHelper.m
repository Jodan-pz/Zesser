//
//  JDNClientHelper.m
//  Zesser
//
//  Created by Daniele Giove on 6/7/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import "JDNClientHelper.h"
#import <QuartzCore/QuartzCore.h>
#import "JDNCity.h"

#define VIEW_BKG_GRADIENT_FROM   [UIColor colorWithRed:0.075 green:0.000 blue:0.615 alpha:1.000]
#define VIEW_BKG_GRADIENT_TO     [UIColor colorWithRed:0.703 green:0.000 blue:0.930 alpha:1.000]

@implementation JDNClientHelper

+(NSString*)cachedDataFileNameForCity:(JDNCity*)city{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *cachedData = [documentsDirectory stringByAppendingPathComponent:
                            [city.name stringByAppendingString:@"_lres.dat"]];
    return cachedData;
}

//Blue gradient background
+ (CAGradientLayer*) blueGradient {
    
    UIColor *colorOne = VIEW_BKG_GRADIENT_FROM;
    UIColor *colorTwo = VIEW_BKG_GRADIENT_TO;
    
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];
    
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil];
    
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = colors;
    headerLayer.locations = locations;
    return headerLayer;
}

+(NSString*)capitalizeFirstCharOfString:(NSString*)aString{
    NSString *txt = [aString stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                     withString:[[aString substringToIndex:1] uppercaseString]];
    return txt;
}

+(NSString*)unescapeString:(NSString*)string{
    NSMutableString *mut = [[NSMutableString alloc] initWithString:string];
    [JDNClientHelper unescapeMutableString:mut];
    return mut;
}

+(void)unescapeMutableString:(NSMutableString*)string{
    [string replaceOccurrencesOfString:@"&amp;"  withString:@"&"  options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"&nbsp;"  withString:@" "  options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"&quot;" withString:@"\"" options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    [string replaceOccurrencesOfString:@"&deg;" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [string length])];

	[string replaceOccurrencesOfString:@"&#x27;" withString:@"'"  options:NSLiteralSearch range:NSMakeRange(0, [string length])];
	[string replaceOccurrencesOfString:@"&#x39;" withString:@"'"  options:NSLiteralSearch range:NSMakeRange(0, [string length])];
	[string replaceOccurrencesOfString:@"&#x92;" withString:@"'"  options:NSLiteralSearch range:NSMakeRange(0, [string length])];
	[string replaceOccurrencesOfString:@"&#x96;" withString:@"'"  options:NSLiteralSearch range:NSMakeRange(0, [string length])];
	[string replaceOccurrencesOfString:@"&gt;"   withString:@">"  options:NSLiteralSearch range:NSMakeRange(0, [string length])];
	[string replaceOccurrencesOfString:@"&lt;"   withString:@"<"  options:NSLiteralSearch range:NSMakeRange(0, [string length])];
}

+(void)configureTemperatureLayoutForLabel:(UILabel*)aView byValue:(NSInteger)value{
    if ( value > 38 ){
        aView.textColor = [UIColor colorWithRed:1.000 green:0.391 blue:0.972 alpha:1.000];
    }else if ( value > 32 ){
        aView.textColor = [UIColor colorWithRed:1.000 green:0.651 blue:0.000 alpha:1.000];
    }else if ( value > 26 ){
        aView.textColor = [UIColor yellowColor];
    }else if( value > 22 ){
        aView.textColor = [UIColor colorWithRed:0.121 green:0.776 blue:0.484 alpha:1.000];
    }else if ( value <= 0){
        aView.textColor = [UIColor cyanColor];
    }else{
        aView.textColor = [UIColor whiteColor];
    }
}

+(BOOL)stringIsNilOrEmpty:(NSString*)aString {
    if (!aString)
        return YES;
    return [aString isEqualToString:@""];
}

+(void)showMessage:(NSString*) message withTitle: (NSString*) title {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:title
                                                 message:message
                                                delegate:nil
                                       cancelButtonTitle:@"Close"
                                       otherButtonTitles: nil];
    [av show];
}

+(void)showYesNo:(NSString*) message withTag:(NSInteger)tag delegate:(id)delegate{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:JDN_QUES_MSG_TITLE
                                                 message:message
                                                delegate:delegate
                                       cancelButtonTitle:@"No"
                                       otherButtonTitles:@"Yes", nil];
    av.tag =  tag;
    [av show];
}

+(void)showInfo:(NSString*) message {
    [JDNClientHelper showMessage:message withTitle:JDN_INFO_MSG_TITLE];
}

+(void)showWarning:(id) warningObject {
    NSString *humanMessage = [warningObject description];
    [JDNClientHelper showMessage:humanMessage withTitle:JDN_WARN_MSG_TITLE];
}

+(void)showError:(id) errorObject {
    NSString *humanMessage = [errorObject description];
    [JDNClientHelper showMessage:humanMessage withTitle:JDN_ERRO_MSG_TITLE];
}

+(void)showBezelMessage:(NSString*) message viewController:(UIViewController*)viewController{
    if ( !viewController ) return;
    
    float viewWidth = viewController.view.bounds.size.width;
    float viewHeight = viewController.view.bounds.size.height;
    float labelWidth = viewWidth - 20;
    float labelHeight = 200;
    
    float xpos = (viewWidth/2.0f) - (labelWidth/2.0f);
    float ypos = (viewHeight/2.0f) - (labelHeight/2.0f);
    
    UIView *viewMessage=[[UIView alloc] initWithFrame:CGRectMake(xpos,ypos,labelWidth,labelHeight) ];
    
    UILabel *txtMessage = [[UILabel alloc] initWithFrame:CGRectMake(0,70,labelWidth,labelHeight-70) ];
    
    [viewMessage setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin |
     UIViewAutoresizingFlexibleRightMargin |
     UIViewAutoresizingFlexibleTopMargin |
     UIViewAutoresizingFlexibleBottomMargin];
    
    [viewController.view addSubview:viewMessage];
    
    txtMessage.textAlignment = NSTextAlignmentCenter;
    txtMessage.textColor = [UIColor whiteColor];
    txtMessage.backgroundColor = [UIColor clearColor];
    txtMessage.text = message;
    txtMessage.font = [UIFont fontWithName:@"Arial" size:26];
    txtMessage.numberOfLines = 6;
    txtMessage.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:JDN_COMMON_IMAGE_INFO];
    imgView.frame = CGRectMake(txtMessage.frame.size.width/2-22, 25, 44 , 44);
    
    viewMessage.backgroundColor = [UIColor blackColor];
    viewMessage.alpha = 0;
    viewMessage.hidden = NO;
    viewMessage.layer.cornerRadius = 20;
    [viewMessage addSubview:imgView];
    [viewMessage addSubview:txtMessage];
    
    [UIView animateWithDuration:.2 animations:^{
        viewMessage.alpha = .8;
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.2
                              delay:1.4
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             viewMessage.alpha = 0;
                         } completion:^(BOOL finished) {
                             
                         }];
    }];
    
}

@end