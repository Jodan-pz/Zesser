//
//  JDNNewCityViewController.h
//  Zesser
//
//  Created by Daniele Giove on 6/7/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JDNNewCityViewController;
@class JDNCity;

@protocol JDNNewCityViewDelegate

-(void)didAddedNewCity:(JDNCity*)newCity
                sender:(JDNNewCityViewController*)sender;

@end

@interface JDNNewCityViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *okButton;

@property (weak, nonatomic) IBOutlet UITextField *city;
@property (weak, nonatomic) IBOutlet UITextField *url;
@property (weak) id<JDNNewCityViewDelegate> delegate;

@end
