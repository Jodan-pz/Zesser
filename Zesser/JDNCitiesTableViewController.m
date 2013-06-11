//
//  JDNCitiesTableViewController.m
//  Zesser
//
//  Created by Daniele Giove on 6/6/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>

#import "JDNCitiesTableViewController.h"
#import "JDNCities.h"
#import "JDNCity.h"
#import "JDNWeatherTableViewController.h"
#import "JDNWeatherFetcher.h"
#import "JDNDailyData.h"
#import "JDNSimpleWeatherCell.h"
#import "JDNNewCityViewController.h"
#import "JDNCitySearchTableViewController.h"

#define REFRESH_TITLE_ATTRIBUTES @{NSForegroundColorAttributeName:[UIColor colorWithRed:0.746 green:0.909 blue:0.936 alpha:1.000] }
#define REFRESH_TINT_COLOR       [UIColor colorWithRed:0.367 green:0.609 blue:0.887 alpha:1.000]
#define NAVIGATION_TINT_COLOR    [UIColor colorWithRed:0.075 green:0.000 blue:0.615 alpha:1.000]

@interface JDNCitiesTableViewController ()<JDNAddCityDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIBarButtonItem   *addCityButton;
@property (strong, nonatomic) UIRefreshControl  *citiesRefreshControl;
@property (strong, nonatomic) NSDate            *lastAvailableCheck;
@property (strong, nonatomic) UIBarButtonItem   *editCitiesBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem   *doneEditCitiesBarButtonItem;

@end

@implementation JDNCitiesTableViewController{
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
}


-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if ( [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
        [self addCityRemovedObserver];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if  (self = [super initWithCoder:aDecoder]){
        [self addCityRemovedObserver];
    }
    return self;
}

- (id)init{
    self = [super init];
    if (self) {
        [self addCityRemovedObserver];
    }
    return self;
}

-(void)addCityRemovedObserver{
    // register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleCityRemoved:)
                                                 name:CITY_REMOVED_NOTIFICATION
                                               object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self ];
}

-(void)handleCityRemoved:(NSNotification*)notification{
    JDNCity *city = notification.object;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *cachedData = [documentsDirectory stringByAppendingPathComponent: [city.name stringByAppendingString:@"_lres.dat"]];
    if ( [[NSFileManager defaultManager] fileExistsAtPath:cachedData] ){
        [[NSFileManager defaultManager] removeItemAtPath:cachedData error:NULL];
    }
}

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

-(void)configureCandEditButton{
    NSArray *cities = [JDNCities sharedCities].cities;
    
    if ( cities.count < 1 || ( cities.count == 1 && ((JDNCity*)cities[0]).order == -1 ) ){
        self.navigationItem.leftBarButtonItem = nil;
    }else{
        
        self.navigationItem.leftBarButtonItem = self.editCitiesBarButtonItem;
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES;
    UIView *gradientView = [[UIView alloc] initWithFrame:self.tableView.frame];
    CAGradientLayer *bgLayer = [JDNClientHelper blueGradient];
    bgLayer.frame = self.tableView.bounds;
    [gradientView.layer insertSublayer:bgLayer atIndex:1];
    self.tableView.backgroundView = gradientView;
    self.refreshControl = self.citiesRefreshControl;
    self.navigationItem.rightBarButtonItem = self.addCityButton;
    
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    currentLocation = [locations objectAtIndex:0];
    [locationManager stopUpdatingLocation];
    NSLog(@"Detected Location : %f, %f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:currentLocation
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       if (error){
                           NSLog(@"Geocode failed with error: %@", error);
                           return;
                       }
                       CLPlacemark *placemark = [placemarks objectAtIndex:0];
                       NSLog(@"%@",placemark.locality);
                   }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = NAVIGATION_TINT_COLOR;
    [self configureCandEditButton];
}

-(void)viewWeather:(UITapGestureRecognizer*)tg{
    [self.navigationController performSegueWithIdentifier:@"viewWeather" sender:tg.view];
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
    if ( self.tableView.editing ) return;
    JDNWeatherFetcher *weatherFetcher =  [[JDNWeatherFetcher alloc] init];
    if( self.lastAvailableCheck &&
        ((int)[[NSDate date] timeIntervalSinceDate:self.lastAvailableCheck] % 60) < 5 ){
        [cell startLoadingData];
        [weatherFetcher fetchNowSimpleDailyDataForCity:city.url withCompletion:^(NSArray *data) {
            [cell setupCellWithDailyData: (JDNDailyData*) data[0]];
        }];
    }else{
        [weatherFetcher isAvailable:^(BOOL available) {
            if ( available ){
                self.lastAvailableCheck = [NSDate date];
                [cell startLoadingData];
                [weatherFetcher fetchNowSimpleDailyDataForCity:city.url withCompletion:^(NSArray *data) {
                    [cell setupCellWithDailyData: (JDNDailyData*) data[0]];
                }];
            }
        }];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return tableView.editing;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        JDNCity *city = [JDNCities sharedCities].cities[indexPath.row];
        [[JDNCities sharedCities] removeCity:city];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
    JDNCity *city = [JDNCities sharedCities].cities[fromIndexPath.row];
    JDNCity *city2 = [JDNCities sharedCities].cities[toIndexPath.row];
    [[JDNCities sharedCities] setOrderForCity:city order:toIndexPath.row];
    [[JDNCities sharedCities] setOrderForCity:city2 order:fromIndexPath.row];
    [[JDNCities sharedCities] write];
}

- (IBAction)editCities:(id)sender {
    [self toggleEditMode];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"viewWeather" sender:[JDNCities sharedCities].cities[indexPath.row]];
}

-(UIBarButtonItem*)editCitiesBarButtonItem{
    if  (!_editCitiesBarButtonItem){
        _editCitiesBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEditMode)];
    }
    return _editCitiesBarButtonItem;
}

-(UIBarButtonItem*)doneEditCitiesBarButtonItem{
    if  (!_doneEditCitiesBarButtonItem){
        _doneEditCitiesBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(toggleEditMode)];
    }
    return _doneEditCitiesBarButtonItem;
    
}

-(void)toggleEditMode{
    if(self.tableView.editing) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self.tableView setEditing:NO animated:YES];
        self.refreshControl = self.citiesRefreshControl;
        self.navigationItem.rightBarButtonItem = self.addCityButton;
        self.navigationItem.leftBarButtonItem = self.editCitiesBarButtonItem;
        [self configureCandEditButton];
    }
    else {
        [self.tableView setEditing:YES animated:YES];
        self.refreshControl = nil;
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = self.doneEditCitiesBarButtonItem;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ( [segue.identifier isEqualToString:@"viewWeather"]){
        JDNWeatherTableViewController *weathController = segue.destinationViewController;
        if ( [sender isKindOfClass:[JDNCity class]]){
            weathController.city = sender;
        }else{
            NSIndexPath* indexPath=[self.tableView indexPathForCell:sender];
            weathController.city = [JDNCities sharedCities].cities[indexPath.row];
        }
    } else if ( [segue.identifier isEqualToString:@"searchCity"]){
        UINavigationController *searchCityController = segue.destinationViewController;
        ((JDNCitySearchTableViewController*) searchCityController.topViewController).delegate = self;
    }
}

-(void)didAddedNewCity:(JDNCity *)newCity sender:(UIViewController *)sender{
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