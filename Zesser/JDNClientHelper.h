//
//  JDNClientHelper.h
//  Zesser
//
//  Created by Daniele Giove on 6/7/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JDNClientHelper : NSObject

+(void)showBezelMessage:(NSString*) message viewController:(UIViewController*)viewController;

+(void)showMessage:(NSString*) message withTitle: (NSString*) title;
+(void)showYesNo:(NSString*) message withTag:(NSInteger)tag delegate:(id)delegate;
+(void)showInfo:(NSString*) message;
+(void)showWarning:(id) warningObject;
+(void)showError:(id) errorObject;

@end
