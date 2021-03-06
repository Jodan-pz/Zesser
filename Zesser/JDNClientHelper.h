//
//  JDNClientHelper.h
//  Zesser
//
//  Created by Daniele Giove on 6/7/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class JDNCity;

@interface JDNClientHelper : NSObject

+(NSString*)cachedDataFileNameForCity:(JDNCity*)city;
+ (CAGradientLayer*) blueGradient;
+(NSString*)capitalizeFirstCharOfString:(NSString*)aString;
+(NSString*)unescapeString:(NSString*)string;
+(void)unescapeMutableString:(NSMutableString*)string;
+(void)configureTemperatureLayoutForLabel:(UILabel*)aView byValue:(NSInteger)value;
+(void)showBezelMessage:(NSString*) message viewController:(UIViewController*)viewController;
+(BOOL)stringIsNilOrEmpty:(NSString*)aString;
+(void)showMessage:(NSString*) message withTitle: (NSString*) title;
+(void)showYesNo:(NSString*) message withTag:(NSInteger)tag delegate:(id)delegate;
+(void)showInfo:(NSString*) message;
+(void)showWarning:(id) warningObject;
+(void)showError:(id) errorObject;

@end
