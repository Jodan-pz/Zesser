//
//  JDNCitiesTableViewController.m
//  Zesser
//
//  Created by Daniele Giove on 6/6/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "JDNCitiesTableViewController.h"
#import "JDNCities.h"
#import "JDNCity.h"
#import "JDNWeatherTableViewController.h"
#import "JDNWeatherFetcher.h"
#import "JDNDailyData.h"
#import "JDNSimpleWeatherCell.h"
#import "JDNNewCityViewController.h"


#define REFRESH_TITLE_ATTRIBUTES @{NSForegroundColorAttributeName:[UIColor colorWithRed:0.746 green:0.909 blue:0.936 alpha:1.000] }
#define REFRESH_TINT_COLOR       [UIColor colorWithRed:0.367 green:0.609 blue:0.887 alpha:1.000]

@interface JDNCitiesTableViewController ()<JDNNewCityViewDelegate>

@property (strong, nonatomic) UIBarButtonItem   *addCityButton;
@property (strong, nonatomic) UIRefreshControl  *citiesRefreshControl;

@end

@implementation JDNCitiesTableViewController

-(UIRefreshControl *)citiesRefreshControl{
    if ( !_citiesRefreshControl){
        _citiesRefreshControl = [[UIRefreshControl alloc] init];
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc]
                                            initWithString:@"Trascina per aggiornare"
                                            attributes:REFRESH_TITLE_ATTRIBUTES];
        
        _citiesRefreshControl.attributedTitle = title;
        
        _citiesRefreshControl.tintColor = REFRESH_TINT_COLOR;
        [_citiesRefreshControl addTarget:self
                           action:@selector(refreshData:)
                 forControlEvents:UIControlEventValueChanged];
    }
    return _citiesRefreshControl;
}

-(UIBarButtonItem *)addCityButton{
    if ( !_addCityButton ){
        _addCityButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCity:)];
    }
    return _addCityButton;
}

//Blue gradient background
+ (CAGradientLayer*) blueGradient {
    
    UIColor *colorOne = [UIColor colorWithRed:0.081 green:0.342 blue:0.664 alpha:1.000];
    UIColor *colorTwo = [UIColor colorWithRed:(57/255.0)  green:(79/255.0)  blue:(96/255.0)  alpha:1.0];
    
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];
    
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil];
    
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    headerLayer.colors = colors;
    headerLayer.locations = locations;
    return headerLayer;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    UIView *gradientView = [[UIView alloc] initWithFrame:self.tableView.frame];
    CAGradientLayer *bgLayer = [JDNCitiesTableViewController blueGradient];
    bgLayer.frame = self.tableView.bounds;
    [gradientView.layer insertSublayer:bgLayer atIndex:1];
    self.tableView.backgroundView = gradientView;
    self.refreshControl = self.citiesRefreshControl;
    self.navigationItem.rightBarButtonItem = self.addCityButton;
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

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.editing) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        JDNCity *city = [JDNCities sharedCities].cities[indexPath.row];
        [[JDNCities sharedCities] removeCity:city];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   

}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    JDNCity *city = [JDNCities sharedCities].cities[fromIndexPath.row];
    JDNCity *city2 = [JDNCities sharedCities].cities[toIndexPath.row];
    [[JDNCities sharedCities] setOrderForCity:city order:toIndexPath.row];
    [[JDNCities sharedCities] setOrderForCity:city2 order:fromIndexPath.row];
    [[JDNCities sharedCities] write];
}

- (IBAction)editCities:(id)sender {
    [self toggleEditMode];
}


-(void)toggleEditMode{
    if(self.tableView.editing) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self.tableView setEditing:NO animated:YES];
        self.refreshControl = self.citiesRefreshControl;
        self.navigationItem.rightBarButtonItem = self.addCityButton;
        self.navigationItem.leftBarButtonItem.style =UIBarButtonItemStyleBordered;
        self.navigationItem.leftBarButtonItem.title = @"Modifica";
    }
    else {
        [self.tableView setEditing:YES animated:YES];
        self.refreshControl = nil;
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem.style =UIBarButtonItemStyleDone;
        self.navigationItem.leftBarButtonItem.title = @"Fatto";
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ( [segue.identifier isEqualToString:@"viewWeather"]){
        JDNWeatherTableViewController *weathControler = segue.destinationViewController;
        NSIndexPath* indexPath=[self.tableView indexPathForCell:sender];
        weathControler.city = [JDNCities sharedCities].cities[indexPath.row];
    } else if ( [segue.identifier isEqualToString:@"newCity"]){
        JDNNewCityViewController *newCityController = segue.destinationViewController;
        newCityController.delegate = self;
    }
               
}

-(void)didAddedNewCity:(JDNCity *)newCity sender:(JDNNewCityViewController *)sender{
    [sender dismissViewControllerAnimated:YES completion:^{
        if ( newCity ){
            [self refreshData:self.refreshControl];
        }
    }];
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