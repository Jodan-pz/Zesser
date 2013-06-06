//
//  JDNAMMeteoTableViewController.m
//  Zesser
//
//  Created by Daniele Giove on 6/5/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import "JDNAMMeteoTableViewController.h"
#import "JDNFetchWeather.h"
#import "JDNDailyData.h"

@interface JDNAMMeteoTableViewController ()

@property (strong,nonatomic) NSArray *data;
@property (strong,nonatomic) JDNFetchWeather *weatherFetcher;
@end

@implementation JDNAMMeteoTableViewController

-(void)refreshData{

    // pozzo : @"3841/POZZO%20D'ADDA"
    // milano :@"87/MILANO"
    
    [self.weatherFetcher fetchDailyDataForCity:@"3841/POZZO%20D'ADDA" withCompletion:^(NSArray *data) {
        self.data = data;
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.weatherFetcher = [JDNFetchWeather new];
    
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if ( cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    // Configure the cell...
    JDNDailyData *dailyData = self.data[indexPath.row];
    cell.textLabel.text =  dailyData.shortDescription;
    NSLog(@"%@", dailyData);
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
