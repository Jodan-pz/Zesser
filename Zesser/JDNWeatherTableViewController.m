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

#define REFRESH_TITLE_ATTRIBUTES @{NSForegroundColorAttributeName:[UIColor colorWithRed:0.746 green:0.909 blue:0.936 alpha:1.000] }
#define REFRESH_TINT_COLOR       [UIColor colorWithRed:0.367 green:0.609 blue:0.887 alpha:1.000]
#define SECTION_BACKGROUND_COLOR [UIColor colorWithRed:0.081 green:0.259 blue:0.504 alpha:1.000]
#define SECTION_FOREGROUND_COLOR [UIColor colorWithRed:0.120 green:0.778 blue:0.769 alpha:1.000]
#define SECTION_SHADOW_COLOR     [UIColor colorWithRed:0.131 green:0.000 blue:0.646 alpha:1.000]

@interface JDNWeatherTableViewController ()

@property (strong,nonatomic) NSDictionary            *data;
@property (strong,nonatomic) NSArray                 *sections;
@property (strong,nonatomic) JDNWeatherFetcher       *weatherFetcher;

@end

@implementation JDNWeatherTableViewController

-(void)refreshData:(UIRefreshControl *)refresh {
    self.sections = nil;
    self.data = nil;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *cachedData = [documentsDirectory stringByAppendingPathComponent: [self.city.name stringByAppendingString:@"_lres.dat"]];
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc]
                                        initWithString:@"Aggiornamento dati..."
                                        attributes:REFRESH_TITLE_ATTRIBUTES];
    refresh.attributedTitle = title;
    
    if ( self.city ){

        self.title = self.city.name;

        [self.weatherFetcher isAvailable:^(BOOL available) {
            
            if ( available ){
                
                [self.weatherFetcher fetchDailyDataForCity:self.city.url withCompletion:^(NSArray *data) {
                    [[NSKeyedArchiver archivedDataWithRootObject:data] writeToFile:cachedData atomically:YES];
                    self.sections = [NSArray array];
                    self.sections = [[data valueForKey:@"day"] distinct];
                    self.data = [data groupBy:^id(JDNDailyData *item) {
                        return item.day;
                    }];
                    
                    [self.tableView reloadData];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"d MMMM yyyy, HH:mm:ss"];
                    NSString *lastUpdated = [NSString stringWithFormat:@"Aggiornato al %@",
                                             [formatter stringFromDate:[NSDate date]]];
                    NSMutableAttributedString *title = [[NSMutableAttributedString alloc]
                                                        initWithString:lastUpdated
                                                        attributes:REFRESH_TITLE_ATTRIBUTES];
                    
                    refresh.attributedTitle = title;
                    [refresh endRefreshing];
                }];
                
                
            }else{
                if ( [[NSFileManager defaultManager] fileExistsAtPath:cachedData] ){
                    [JDNClientHelper showBezelMessage:@"Ultimi dati..." viewController:self];
                    
                    NSArray *data =  [NSKeyedUnarchiver unarchiveObjectWithFile:cachedData];
                    self.sections = [NSArray array];
                    self.sections = [[data valueForKey:@"day"] distinct];
                    self.data = [data groupBy:^id(JDNDailyData *item) {
                        return item.day;
                    }];
                    [self.tableView reloadData];
                    
                }else{
                    [JDNClientHelper showInfo:@"Impossibile recuperare i dati."];
                }
                [refresh endRefreshing];
                return;
            }
           
        }];
        
    }else{
        [refresh endRefreshing];
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.weatherFetcher = [[JDNWeatherFetcher alloc] init];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc]
                                        initWithString:@"Trascina per aggiornare"
                                        attributes:REFRESH_TITLE_ATTRIBUTES];
    
    refreshControl.attributedTitle = title;
    
    refreshControl.tintColor = REFRESH_TINT_COLOR;
    [refreshControl addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    [self.refreshControl beginRefreshing];
    [self refreshData:refreshControl];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sections.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    label.backgroundColor = SECTION_BACKGROUND_COLOR;
    label.textColor = SECTION_FOREGROUND_COLOR;
    label.shadowColor = SECTION_SHADOW_COLOR;
    label.shadowOffset = CGSizeMake(-1.0, 1.0);
    label.font = [UIFont systemFontOfSize:18];
    label.text = sectionTitle;
    label.textAlignment = NSTextAlignmentCenter;
    
    UIView *view = [[UIView alloc] initWithFrame:label.frame];
    [view addSubview:label];
    return view;
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

@end