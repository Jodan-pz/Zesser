//
//  JDNClientHelper.m
//  Zesser
//
//  Created by Daniele Giove on 6/7/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import "JDNClientHelper.h"
#import <QuartzCore/QuartzCore.h>

@implementation JDNClientHelper

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
        aView.textColor = [UIColor colorWithRed:0.986 green:0.000 blue:0.029 alpha:1.000];
    }else if ( value > 32 ){
        aView.textColor = [UIColor orangeColor];
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
