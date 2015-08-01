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
#import "JDNItalyCityUrlSearcher.h"
#import "JDNWeatherDataDelegate.h"

#define NAVIGATION_TINT_COLOR    [UIColor colorWithRed:0.075 green:0.000 blue:0.615 alpha:1.000]

@interface JDNCitiesTableViewController ()<JDNAddCityDelegate, JDNFindMyPlaceDelegate, JDNWeatherDataDelegate>

@property (strong, nonatomic) UIBarButtonItem       *addCityButton;
@property (strong, nonatomic) UIRefreshControl      *citiesRefreshControl;
@property (strong, nonatomic) NSDate                *lastAvailableCheck;
@property (strong, nonatomic) UIBarButtonItem       *editCitiesBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem       *doneEditCitiesBarButtonItem;
@property (strong, nonatomic) JDNFindMyPlace        *findMyPlace;
@property (strong, nonatomic) JDNCitySearcher       *citySearcher;
@property (strong, nonatomic) NSMutableDictionary   *currentDailyData;
@property (strong, nonatomic) NSMutableArray        *reorderingRows;
@property (atomic)            BOOL                  isRefreshingData;
@property (strong, nonatomic) JDNCity               *cityToReload;

@end

@implementation JDNCitiesTableViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
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
    self.citiesRefreshControl.backgroundColor = REFRESH_BACKGROUND_COLOR;
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
    
    // set data source
    self.reorderingRows = [[[JDNCities sharedCities] cities] mutableCopy];
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

-(void)configureCanEditButton{
    NSArray *cities = [[JDNCities sharedCities] cities];
    if ( cities.count < 1 || ( cities.count == 1 && ((JDNCity*)cities[0]).isFixed ) ){
        self.navigationItem.leftBarButtonItem = nil;
    }else{
        self.navigationItem.leftBarButtonItem = self.editCitiesBarButtonItem;
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES;
    self.refreshControl = self.citiesRefreshControl;
    
    UIView *gradientView = [[UIView alloc] initWithFrame:self.tableView.frame];
    CAGradientLayer *bgLayer = [JDNClientHelper blueGradient];
    bgLayer.frame = self.tableView.bounds;
    [gradientView.layer insertSublayer:bgLayer atIndex:1];
    self.tableView.backgroundView = gradientView;
    
    self.refreshControl.layer.zPosition = self.tableView.backgroundView.layer.zPosition + 1;
    
    self.navigationItem.rightBarButtonItem = self.addCityButton;
    
    // first refresh data...
    [self.refreshControl setAccessibilityIdentifier:@"doNotReload"];
    
    [self refreshData:self.refreshControl];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];

    self.navigationController.navigationBar.tintColor = NAVIGATION_TINT_COLOR;
    [self configureCanEditButton];
}

-(void)viewDidAppear:(BOOL)animated{
    if ( self.cityToReload ){
        NSUInteger cityIndex = [self.reorderingRows indexOfObject:self.cityToReload];
        JDNSimpleWeatherCell *cityCell = (JDNSimpleWeatherCell*) [self.tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow:cityIndex inSection:0]];
        // remove from cache for reload!
        [self.currentDailyData removeObjectForKey:self.cityToReload.name];
        [self updateWeatherDataForCity:self.cityToReload inCell:cityCell];
        self.cityToReload = nil;
    }
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.reorderingRows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    
    JDNCity *city = self.reorderingRows[indexPath.row];
    JDNSimpleWeatherCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                           forIndexPath:indexPath];
    
    // selection background view (IOS7)
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:0.000
                                                  green:0.502
                                                   blue:1.000
                                                  alpha:1.000];
    bgColorView.layer.masksToBounds = YES;
    
    cell.selectedBackgroundView = bgColorView;
    cell.cityName.text = city.name;
    
    if ( city.isFixed ){
        // change disclosure to flag mark!
        cell.accessoryView = [[UIImageView alloc] initWithImage:JDN_COMMON_IMAGE_HERE];
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [cell prepareForCity:city];
    [self updateWeatherDataForCity:city inCell:cell];
    
    return cell;
}

-(void)updateWeatherDataForCity: (JDNCity*)city inCell: (JDNSimpleWeatherCell*)cell {
    // check current daily (speedup)
    NSArray *data = [self.currentDailyData valueForKey:city.name];
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
            [self.currentDailyData setValue:data forKey:city.name];
        }];
    }else{
        [weatherFetcher isAvailable:^(BOOL available) {
            if ( available ){
                self.lastAvailableCheck = [NSDate date];
                [cell startLoadingData];
                [weatherFetcher fetchDailyDataForCity:city withCompletion:^(NSArray *data) {
                    [cell setupCellForCity:city withDailyData: data];
                    [self.currentDailyData setValue:data forKey:city.name];
                }];
            }
        }];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    JDNCity *city = self.reorderingRows[indexPath.row];
    return city.order >=0 && tableView.editing;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        JDNCity *city = self.reorderingRows[indexPath.row];
        [[JDNCities sharedCities] removeCity:city];
        [self.currentDailyData removeObjectForKey:city.name];
        [self.reorderingRows removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    JDNCity *city = self.reorderingRows[indexPath.row];
    return city.order >=0;
}

-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath{
    JDNCity *destCity = self.reorderingRows[proposedDestinationIndexPath.row];
    if (destCity.order >= 0){
        return proposedDestinationIndexPath;
    }
    return sourceIndexPath;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
    JDNCity *cityToMove = self.reorderingRows[fromIndexPath.row];
    [self.reorderingRows removeObjectAtIndex:fromIndexPath.row];
    [self.reorderingRows insertObject:cityToMove atIndex:toIndexPath.row];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    if ( self.tableView.editing ) return;
    [self performSegueWithIdentifier:@"viewWeather" sender:self.reorderingRows[indexPath.row]];
}

-(void)updateCitiesOrder{
    [[JDNCities sharedCities] removeDynamicCities];
    for (NSUInteger pos = 0; pos < self.reorderingRows.count; pos++) {
        JDNCity *city = self.reorderingRows[pos];
        if ( city.isFixed ) continue;
        [[JDNCities sharedCities] addCity:city];
    }
    [[JDNCities sharedCities] write];
}

-(void)toggleEditMode{
    if(self.tableView.editing) {
        [self updateCitiesOrder];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self.tableView setEditing:NO animated:YES];
        self.refreshControl = self.citiesRefreshControl;
        self.navigationItem.rightBarButtonItem = self.addCityButton;
        self.navigationItem.leftBarButtonItem = self.editCitiesBarButtonItem;
        [self configureCanEditButton];
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
            weatherController.city =  self.reorderingRows[indexPath.row];
        }
        weatherController.currentDailyData = self.currentDailyData[weatherController.city.name];
        weatherController.delegate = self;
    } else if ( [segue.identifier isEqualToString:@"searchCity"]){
        UINavigationController *searchCityController = segue.destinationViewController;
        ((JDNCitySearchTableViewController*) searchCityController.topViewController).delegate = self;
    }
}

-(void)didAddedNewCity:(JDNCity *)newCity sender:(UIViewController *)sender{
    [sender dismissViewControllerAnimated:YES completion:^{
        if ( newCity ){
            self.reorderingRows = [[[JDNCities sharedCities] cities]  mutableCopy];
            [self.tableView reloadData];
        }
    }];
}

-(void)weatherDataChangedForCity:(JDNCity *)city{
    // reload city row...
    self.cityToReload = city;
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
        
        // update data source
        self.reorderingRows = [[[JDNCities sharedCities] cities] mutableCopy];
        
        if ([self.refreshControl.accessibilityIdentifier  isEqualToString:@"doNotReload"]) {
            [self.refreshControl setAccessibilityIdentifier:nil];
        }else{
            [self.tableView reloadData];
        }
        
        self.isRefreshingData = NO;
        self.editCitiesBarButtonItem.enabled = self.addCityButton.enabled = YES;
    });
}

-(JDNCity*)matchExactCityName:(NSString*)name inArray:(NSArray*)data{
    
    NSArray *matches = [data filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(JDNCity *city, NSDictionary *bindings) {
        return [self isValidCityName:name withFullName:city.name];
    }]];
    
    return [matches firstObject];
 //   || ![self isValidCityName:placeToFind withFullName:firstFound.name]
}

-(void)findMyPlaceDidFoundCurrentLocation:(JDNPlace *)place{
    if( !place || !place.isItaly ){
        [self finalizeRefreshAction];
        return;
    }

    if ( !self.citySearcher ){
        self.citySearcher = [[JDNCitySearcher alloc] init];
    }
    JDNCity *oldFixedCity = [self.reorderingRows firstOrNil];
    if ( oldFixedCity && !oldFixedCity.isFixed ) oldFixedCity = nil;
    
    __block NSString *placeToFind = place.locality;
    __block JDNCity  *firstFound;
    
    [self.citySearcher searchPlaceByText:placeToFind includeWorld:NO withCompletion:^(NSArray *data) {
        
        // match exact name
        firstFound = [self matchExactCityName:placeToFind inArray:data];
        
        if (!firstFound) {
        
            placeToFind = place.subAreaLocality;
            
            [self.citySearcher searchPlaceByText:placeToFind includeWorld:NO withCompletion:^(NSArray *data) {
                firstFound = [data firstOrNil];
                
                if ( firstFound ){
                    [self setMyPlace:firstFound replacingOldFixedCity:oldFixedCity];
                }else{
                    self.refreshControl.accessibilityIdentifier = nil;
                    [self finalizeRefreshAction];
                }
                
            }];
        }else{
            [self setMyPlace:firstFound replacingOldFixedCity:oldFixedCity];
        }
    }];
}

-(void) setMyPlace:(JDNCity *) city replacingOldFixedCity:(JDNCity*)oldFixedCity{
    [city setFixed];
    [[JDNCities sharedCities] updateOrAddByOldCity:oldFixedCity andNewCity:city];
    [[JDNCities sharedCities] write];
    
    // try to fetch city url if italy (txxx glg!!!)
    if ( city.isInItaly ){
        JDNItalyCityUrlSearcher *urlSearch = [JDNItalyCityUrlSearcher new];
        [urlSearch searchCityUrlByText:city.name
                        withCompletion:^(NSString *data) {
                            if (data) city.url = data;
                            self.refreshControl.accessibilityIdentifier = nil;
                            [self finalizeRefreshAction];
                        }];
    }else{
        self.refreshControl.accessibilityIdentifier = nil;
        [self finalizeRefreshAction];
    }
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