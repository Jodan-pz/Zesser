//
//  JDNNewCityViewController.h
//  Zesser
//
//  Created by Daniele Giove on 6/7/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDNAddCityDelegate.h"

@interface JDNNewCityViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *okButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *cityName;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UITextField *url;
@property (weak) id<JDNAddCityDelegate> delegate;
@property (nonatomic)        BOOL    showUrl;
@property (strong,nonatomic) JDNCity *city;


@end