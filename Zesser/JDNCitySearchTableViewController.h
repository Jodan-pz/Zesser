//
//  JDNCitySearchTableViewController.h
//  Zesser
//
//  Created by Daniele Giove on 6/10/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JDNAddCityDelegate.h"

@interface JDNCitySearchTableViewController : UITableViewController

@property (weak) id<JDNAddCityDelegate> delegate;

@end