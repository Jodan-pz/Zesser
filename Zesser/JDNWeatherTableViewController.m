//
//  JDNAMMeteoTableViewController.m
//  Zesser
//
//  Created by Daniele Giove on 6/5/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import "JDNWeatherTableViewController.h"
#import "JDNWeatherFetcher.h"
#import "JDNDailyData.h"
#import "JDNCity.h"
#import "JDNWeatherCell.h"

@interface JDNWeatherTableViewController ()

@property (strong,nonatomic) NSArray *data;
@property (strong,nonatomic) JDNWeatherFetcher *weatherFetcher;
@end

@implementation JDNWeatherTableViewController

-(void)refreshData{
    if ( self.city){
        self.title = self.city.name;
        [self.weatherFetcher fetchDailyDataForCity:self.city.url withCompletion:^(NSArray *data) {
            self.data = data;
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.weatherFetcher = [JDNWeatherFetcher new];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                        init];
    refreshControl.tintColor = [UIColor lightGrayColor];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self refreshData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    JDNWeatherCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if ( cell == nil){
        cell = [[JDNWeatherCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    JDNDailyData *dailyData = self.data[indexPath.row];
    [cell setupCellWithDailyData:dailyData];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
