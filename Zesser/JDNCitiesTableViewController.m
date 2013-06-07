//
//  JDNCitiesTableViewController.m
//  Zesser
//
//  Created by Daniele Giove on 6/6/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import "JDNCitiesTableViewController.h"
#import "JDNCities.h"
#import "JDNCity.h"
#import "JDNWeatherTableViewController.h"
#import "JDNWeatherFetcher.h"
#import "JDNDailyData.h"
#import "JDNSimpleWeatherCell.h"

#define REFRESH_TITLE_ATTRIBUTES @{NSForegroundColorAttributeName:[UIColor colorWithRed:0.746 green:0.909 blue:0.936 alpha:1.000] }
#define REFRESH_TINT_COLOR       [UIColor colorWithRed:0.367 green:0.609 blue:0.887 alpha:1.000]

@interface JDNCitiesTableViewController ()

@end

@implementation JDNCitiesTableViewController

- (void)viewDidLoad{
    [super viewDidLoad];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc]
                                        initWithString:@"Trascina per aggiornare"
                                        attributes:REFRESH_TITLE_ATTRIBUTES];
    
    refreshControl.attributedTitle = title;
    
    refreshControl.tintColor = REFRESH_TINT_COLOR;
    [refreshControl addTarget:self
                       action:@selector(refreshData:)
             forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [JDNCities sharedCities].cities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    JDNCity *city = [JDNCities sharedCities].cities[indexPath.row];
    
    JDNSimpleWeatherCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.cityName.text = city.name;
    
    [cell clear];
    [self updateWeatherDataForCity:city
                            inCell:cell];

    return cell;
}

-(void)updateWeatherDataForCity: (JDNCity*)city inCell: (JDNSimpleWeatherCell*)cell {
    JDNWeatherFetcher *weatherFetcher =  [[JDNWeatherFetcher alloc] init];
    [weatherFetcher isAvailable:^(BOOL available) {
        if ( available ){
            [cell startLoadingData];
            [weatherFetcher fetchNowSimpleDailyDataForCity:city.url withCompletion:^(NSArray *data) {
                [cell setupCellWithDailyData: (JDNDailyData*) data[0]];
            }];
        }
    }];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ( [segue.identifier isEqualToString:@"viewWeather"]){
        JDNWeatherTableViewController *weathControler = segue.destinationViewController;
        NSIndexPath* indexPath=[self.tableView indexPathForCell:sender];
        weathControler.city = [JDNCities sharedCities].cities[indexPath.row];
    }
}


-(void)refreshData:(UIRefreshControl *)refresh {
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc]
                                        initWithString:@"Aggiornamento dati..."
                                        attributes:REFRESH_TITLE_ATTRIBUTES];
    refresh.attributedTitle = title;
    
    [self.tableView reloadData];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"d MMMM yyyy, HH:mm:ss"];
    NSString *lastUpdated = [NSString stringWithFormat:@"Aggiornato al %@",
                             [formatter stringFromDate:[NSDate date]]];
    NSMutableAttributedString *update = [[NSMutableAttributedString alloc]
                                        initWithString:lastUpdated
                                        attributes:REFRESH_TITLE_ATTRIBUTES];
    
    refresh.attributedTitle = update;
    [refresh endRefreshing];
}

@end