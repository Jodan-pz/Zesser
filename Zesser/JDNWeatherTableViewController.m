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
#import "NSArray+LinqExtensions.h"

@interface JDNWeatherTableViewController ()

@property (strong,nonatomic) NSDictionary       *data;
@property (strong,nonatomic) NSMutableArray     *sections;
@property (strong,nonatomic) JDNWeatherFetcher  *weatherFetcher;
@end

@implementation JDNWeatherTableViewController

-(void)refreshData:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Aggiornamento dati..."];

    self.data = nil;
    [self.tableView reloadData];
    
    if ( self.city ){
        self.title = self.city.name;
        [self.weatherFetcher fetchDailyDataForCity:self.city.url withCompletion:^(NSArray *data) {
            self.data = [data groupBy:^id(JDNDailyData *item) {
                return item.day;
            }];
            
            self.sections = [NSMutableArray array];
            for (NSString *section in self.data) {
                [self.sections addObject:section];
            }
            
            [self.tableView reloadData];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"d MMMM yyyy, HH:mm:ss"];
            NSString *lastUpdated = [NSString stringWithFormat:@"Aggiornato al %@",
                                     [formatter stringFromDate:[NSDate date]]];
            refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
            [refresh endRefreshing];
        }];
    }else{
        [refresh endRefreshing];
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.weatherFetcher = [[JDNWeatherFetcher alloc] init];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Trascina per aggiornare"];
    refreshControl.tintColor = [UIColor lightGrayColor];
    [refreshControl addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    [self.refreshControl beginRefreshing];
    [self refreshData:refreshControl];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sections.count;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return self.sections[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *data = [self.data valueForKey: self.sections[section]];
    return data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    JDNWeatherCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if ( cell == nil){
        cell = [[JDNWeatherCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    JDNDailyData *dailyData = [self.data valueForKey: self.sections[indexPath.section]][indexPath.row];
    [cell setupCellWithDailyData:dailyData];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
