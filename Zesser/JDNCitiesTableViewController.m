//
//  JDNCitiesTableViewController.m
//  Zesser
//
//  Created by Daniele Giove on 6/6/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>

#import "NSArray+LinqExtensions.h"
#import "JDNCitiesTableViewController.h"
#import "JDNCities.h"
#import "JDNCity.h"
#import "JDNWeatherTableViewController.h"
#import "JDNWeatherFetcher.h"
#import "JDNDailyData.h"
#import "JDNSimpleWeatherCell.h"
#import "JDNNewCityViewController.h"
#import "JDNCitySearchTableViewController.h"
#import "JDNFindMyPlace.h"
#import "JDNCitySearcher.h"
#import "JDNPlace.h"

#define REFRESH_TITLE_ATTRIBUTES @{NSForegroundColorAttributeName:[UIColor colorWithRed:0.746 green:0.909 blue:0.936 alpha:1.000] }
#define REFRESH_TINT_COLOR       [UIColor colorWithRed:0.367 green:0.609 blue:0.887 alpha:1.000]
#define NAVIGATION_TINT_COLOR    [UIColor colorWithRed:0.075 green:0.000 blue:0.615 alpha:1.000]

@interface JDNCitiesTableViewController ()<JDNAddCityDelegate, JDNFindMyPlaceDelegate>

@property (strong, nonatomic) UIBarButtonItem       *addCityButton;
@property (strong, nonatomic) UIRefreshControl      *citiesRefreshControl;
@property (strong, nonatomic) NSDate                *lastAvailableCheck;
@property (strong, nonatomic) UIBarButtonItem       *editCitiesBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem       *doneEditCitiesBarButtonItem;
@property (strong, nonatomic) JDNFindMyPlace        *findMyPlace;
@property (strong, nonatomic) JDNCitySearcher       *citySearcher;
@property (strong, nonatomic) NSMutableDictionary   *currentDailyData;
@property (atomic)            BOOL                  isRefreshingData;

@end

@implementation JDNCitiesTableViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if ( [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
        [self setupCitiesManager];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if  (self = [super initWithCoder:aDecoder]){
        [self setupCitiesManager];
    }
    return self;
}

- (id)init{
    self = [super init];
    if (self) {
        [self setupCitiesManager];
    }
    return self;
}

-(void)setupCitiesManager{    
    // register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleCityRemoved:)
                                                 name:CITY_REMOVED_NOTIFICATION
                                               object:nil];
    self.citiesRefreshControl = [[UIRefreshControl alloc] init];
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc]
                                        initWithString:@"Trascina per aggiornare"
                                        attributes:REFRESH_TITLE_ATTRIBUTES];
    
    self.citiesRefreshControl.attributedTitle = title;
    
    self.citiesRefreshControl.tintColor = REFRESH_TINT_COLOR;
    [self.citiesRefreshControl addTarget:self
                              action:@selector(refreshData:)
                    forControlEvents:UIControlEventValueChanged];
    
    self.addCityButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                       target:self
                                                                       action:@selector(addCity:)];
    self.editCitiesBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                 target:self
                                                                                 action:@selector(toggleEditMode)];
    self.doneEditCitiesBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                     target:self
                                                                                     action:@selector(toggleEditMode)];
    self.findMyPlace = [[JDNFindMyPlace alloc] init];
    self.findMyPlace.delegate = self;
    self.currentDailyData = [NSMutableDictionary dictionary];
    
    self.isRefreshingData = NO;
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
    
    // first refresh data...
    [self refreshData:self.refreshControl];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.tintColor = NAVIGATION_TINT_COLOR;
    [self configureCandEditButton];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [JDNCities sharedCities].cities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    JDNCity *city = [JDNCities sharedCities].cities[indexPath.row];
    JDNSimpleWeatherCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                           forIndexPath:indexPath];
    cell.cityName.text = city.name;
    
    if ( city.order == -1 ){
        // change disclosure to flag mark!
        cell.accessoryView = [[UIImageView alloc] initWithImage:JDN_COMMON_IMAGE_HERE];
    }else{
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    
    [cell prepareForCity:city];
    [self updateWeatherDataForCity:city inCell:cell];
    
    return cell;
}

-(void)updateWeatherDataForCity: (JDNCity*)city inCell: (JDNSimpleWeatherCell*)cell {
    // check current daily (speedup)
    NSArray *data = [self.currentDailyData valueForKey:city.key];
    if(data){
        [cell setupCellForCity:city withDailyData: data];
        return;
    }
    
    JDNWeatherFetcher *weatherFetcher =  [[JDNWeatherFetcher alloc] init];
    if( self.lastAvailableCheck &&
        ((int)[[NSDate date] timeIntervalSinceDate:self.lastAvailableCheck] % 60) < 5 ){
        [cell startLoadingData];
        [weatherFetcher fetchDailyDataForCity:city withCompletion:^(NSArray *data) {
            [cell setupCellForCity:city withDailyData: data];
            [self.currentDailyData setValue:data forKey:city.key];
        }];
    }else{
        [weatherFetcher isAvailable:^(BOOL available) {
            if ( available ){
                self.lastAvailableCheck = [NSDate date];
                [cell startLoadingData];
                [weatherFetcher fetchDailyDataForCity:city withCompletion:^(NSArray *data) {
                    [cell setupCellForCity:city withDailyData: data];
                    [self.currentDailyData setValue:data forKey:city.key];
                }];
            }
        }];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    JDNCity *city = [JDNCities sharedCities].cities[indexPath.row];
    return city.order >=0 && tableView.editing;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        JDNCity *city = [JDNCities sharedCities].cities[indexPath.row];
        [[JDNCities sharedCities] removeCity:city];
        [self.currentDailyData removeObjectForKey:city.key];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    JDNCity *city = [JDNCities sharedCities].cities[indexPath.row];
    return city.order >=0;
}

-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath{
    JDNCity *destCity = [JDNCities sharedCities].cities[proposedDestinationIndexPath.row];
    if (destCity.order >= 0){
        return proposedDestinationIndexPath;
    }
    return sourceIndexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
    JDNCity *city = [JDNCities sharedCities].cities[fromIndexPath.row];
    JDNCity *city2 = [JDNCities sharedCities].cities[toIndexPath.row];
    NSInteger orderFrom = city.order;
    NSInteger orderTo = city2.order;
    if ( [city isEqualToCity:city2]) return;
    [[JDNCities sharedCities] setOrderForCity:city order:orderTo];
    [[JDNCities sharedCities] setOrderForCity:city2 order:orderFrom];
    [[JDNCities sharedCities] write];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    if ( self.tableView.editing ) return;
    [self performSegueWithIdentifier:@"viewWeather" sender:[JDNCities sharedCities].cities[indexPath.row]];
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
        JDNWeatherTableViewController *weatherController = segue.destinationViewController;
        if ( [sender isKindOfClass:[JDNCity class]]){
            weatherController.city = sender;
        }else{
            NSIndexPath* indexPath = [self.tableView indexPathForCell:sender];
            weatherController.city = [JDNCities sharedCities].cities[indexPath.row];
        }
        weatherController.currentDailyData = self.currentDailyData[weatherController.city.key];
    } else if ( [segue.identifier isEqualToString:@"searchCity"]){
        UINavigationController *searchCityController = segue.destinationViewController;
        ((JDNCitySearchTableViewController*) searchCityController.topViewController).delegate = self;
    }
}

-(void)didAddedNewCity:(JDNCity *)newCity sender:(UIViewController *)sender{
    [sender dismissViewControllerAnimated:YES completion:^{
        if ( newCity ){
            [self.tableView reloadData];
        }
    }];
}

-(void)refreshData:(UIRefreshControl *)refresh {
    if ( !self.isRefreshingData ) {
        self.editCitiesBarButtonItem.enabled = self.addCityButton.enabled = NO;
        self.isRefreshingData = YES;
        [self.currentDailyData removeAllObjects];
        [self.findMyPlace startSearchingCurrentLocation];
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc]
                                            initWithString:@"Aggiornamento dati..."
                                            attributes:REFRESH_TITLE_ATTRIBUTES];
        refresh.attributedTitle = title;
    }
}

-(void)finalizeRefreshAction{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"d MMMM yyyy, HH:mm:ss"];
        NSString *lastUpdated = [NSString stringWithFormat:@"Aggiornato al %@",
                                 [formatter stringFromDate:[NSDate date]]];
        NSMutableAttributedString *update = [[NSMutableAttributedString alloc]
                                             initWithString:lastUpdated
                                             attributes:REFRESH_TITLE_ATTRIBUTES];
        self.refreshControl.attributedTitle = update;
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
        
        self.isRefreshingData = NO;
        self.editCitiesBarButtonItem.enabled = self.addCityButton.enabled = YES;
    });
}

-(void)findMyPlaceDidFoundCurrentLocation:(JDNPlace *)place{
    if( !place || !place.isItaly ){
        [self finalizeRefreshAction];
        return;
    }

    if ( !self.citySearcher ){
        self.citySearcher = [[JDNCitySearcher alloc] init];
    }
    JDNCity *oldFixedCity = [[JDNCities sharedCities].cities firstOrNil];
    if ( oldFixedCity && oldFixedCity.order != -1) oldFixedCity = nil;
    
    __block NSString *placeToFind = place.locality;
    __block JDNCity  *firstFound;
    
    [self.citySearcher searchPlaceByText:placeToFind includeWorld:NO withCompletion:^(NSArray *data) {
        firstFound = [data firstOrNil];
        
        if (!firstFound || ![self isValidCityName:placeToFind withFullName:firstFound.name]) {
        
            placeToFind = place.subAreaLocality;
            
            [self.citySearcher searchPlaceByText:placeToFind includeWorld:NO withCompletion:^(NSArray *data) {
                firstFound = [data firstOrNil];
                
                if ( firstFound && [self isValidCityName:placeToFind withFullName:firstFound.name] ){
                    firstFound.order = -1;
                    [[JDNCities sharedCities] updateOrAddByOldCity:oldFixedCity andNewCity:firstFound];
                }
                [self finalizeRefreshAction];
                
            }];
        }else{
            firstFound.order = -1;
            [[JDNCities sharedCities] updateOrAddByOldCity:oldFixedCity andNewCity:firstFound];
            [self finalizeRefreshAction];
        }
    }];
}

-(BOOL) isValidCityName:(NSString*)name withFullName:(NSString*)fullName{
    NSRange rng = [fullName rangeOfString:@"("];
    NSString *tmp = fullName;
    if ( rng.location != NSNotFound){
        tmp = [[fullName substringToIndex:rng.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    return [name caseInsensitiveCompare:tmp] == NSOrderedSame;
}

@end