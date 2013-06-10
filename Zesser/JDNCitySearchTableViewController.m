//
//  JDNCitySearchTableViewController.m
//  Zesser
//
//  Created by Daniele Giove on 6/10/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import "JDNCitySearchTableViewController.h"
#import "JDNCitySearcher.h"
#import "JDNCity.h"
#import "JDNNewCityViewController.h"

#define NAVIGATION_TINT_COLOR    [UIColor colorWithRed:0.075 green:0.000 blue:0.615 alpha:1.000]

@interface JDNCitySearchTableViewController ()<JDNAddCityDelegate, UISearchBarDelegate>

@property (strong,nonatomic)  UIActivityIndicatorView   *loadSpinner;

@end

@implementation JDNCitySearchTableViewController{
    BOOL _isSearching;
    NSMutableArray* _filteredList;
    JDNCitySearcher* _citySearcher;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    _isSearching = NO;
    _filteredList = [NSMutableArray array];
    _citySearcher = [[JDNCitySearcher alloc] init];
    _loadSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loadSpinner.center = CGPointMake( 200, 22 );
    _loadSpinner.hidesWhenStopped = YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.searchDisplayController.searchBar.tintColor = NAVIGATION_TINT_COLOR;
    self.navigationController.navigationBar.tintColor = NAVIGATION_TINT_COLOR;
    UIView *gradientView = [[UIView alloc] initWithFrame:self.tableView.frame];
    CAGradientLayer *bgLayer = [JDNClientHelper blueGradient];
    bgLayer.frame = self.tableView.bounds;
    [gradientView.layer insertSublayer:bgLayer atIndex:1];
    self.tableView.backgroundView = gradientView;
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.searchDisplayController.searchBar becomeFirstResponder];
}

- (IBAction)cancelCitySearch:(id)sender {
    if ( self.delegate ){
        [self.delegate didAddedNewCity:nil sender:self];
    }
}

- (void)filterListForSearchText:(NSString *)searchText sender:(UISearchBar*)sender{
    if ( _isSearching ) return;
    
    if( self.loadSpinner.superview != sender){
        [sender addSubview:self.loadSpinner];
    }
    _isSearching = YES;
    // search
    [self.loadSpinner startAnimating];
    [_filteredList removeAllObjects];
    [_citySearcher searchPlaceByText:searchText withCompletion:^(NSArray *data) {
        [self.loadSpinner stopAnimating];
        for (JDNCity *city in data) {
            [_filteredList addObject:city];
        }
        _isSearching = NO;
        
        [self.searchDisplayController.searchResultsTableView reloadData];
    }];
}

#pragma mark - UISearchDisplayControllerDelegate

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    self.searchDisplayController.searchResultsTableView.backgroundColor= [UIColor colorWithRed:0.458 green:0.268 blue:0.886 alpha:1.000];
    return YES;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [_filteredList removeAllObjects];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self filterListForSearchText:searchBar.text sender:searchBar];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.searchDisplayController.searchResultsTableView){
        return _filteredList.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"SearchCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        cell.accessoryView.userInteractionEnabled = YES;
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    NSString *title;
    if (tableView == self.searchDisplayController.searchResultsTableView && _filteredList.count){
        //If the user is searching, use the list in our filteredList array.
        JDNCity *city = [_filteredList objectAtIndex:indexPath.row];
        title = city.name;
    } else {
        title = @"No data...";
    }
    cell.textLabel.text = title;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.searchDisplayController.searchResultsTableView){
        [self performSegueWithIdentifier:@"newCity" sender: _filteredList[indexPath.row]];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(JDNCity*)city{
    if( [segue.identifier isEqualToString:@"newCity"]){
        JDNNewCityViewController *newCityController = segue.destinationViewController;
        newCityController.showUrl = NO;
        newCityController.city = city;
        newCityController.delegate = self;
    }
}

-(void)didAddedNewCity:(JDNCity *)newCity sender:(UIViewController *)sender{
    if ( self.delegate && newCity ){
        [self.delegate didAddedNewCity:newCity sender:self];
    }else{
        [sender.navigationController popViewControllerAnimated:YES];
    }
}

@end