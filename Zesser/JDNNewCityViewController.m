//
//  JDNNewCityViewController.m
//  Zesser
//
//  Created by Daniele Giove on 6/7/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import "JDNNewCityViewController.h"
#import "JDNCity.h"
#import "JDNCities.h"

@interface JDNNewCityViewController ()<UITextFieldDelegate>

@end

@implementation JDNNewCityViewController

-(void)hideUrl{
    self.url.alpha = 0;
    self.urlLabel.alpha = 0;
    self.cityName.returnKeyType = UIReturnKeyDone;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ( textField.returnKeyType == UIReturnKeyDone ){
        [self addCity:textField];
        return YES;
    }else if ( textField == self.cityName ){
        if ( self.url.alpha ){
            [self.url becomeFirstResponder];
        }else{
            [textField resignFirstResponder];
        }
    }
    return NO;
}

- (IBAction)cancelAddCity:(id)sender {
    if ( self.delegate ){
        [self.delegate didAddedNewCity:nil
                                sender:self];
    }
}

- (IBAction)addCity:(id)sender {
    if ( self.delegate ){
        JDNCity *city = [[JDNCity alloc] init];
        city.name = self.cityName.text;
        city.url = self.url.text;
        city.isInItaly = self.city.isInItaly;
        if  ([[JDNCities sharedCities] addCity:city] ){
            [self.delegate didAddedNewCity:city
                                    sender:self];
        }else{
            [JDNClientHelper showWarning:@"Il nome è già presente!"];
        }
    }
}

-(void)checkIfCanAddNewCity{
    self.okButton.enabled = NO;
    NSString *a = [self.cityName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *b = [self.url.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.okButton.enabled = a.length /* && b.length*/;
}

- (IBAction)cityEditingChanged:(id)sender {
    [self checkIfCanAddNewCity];
}

- (IBAction)urlEditingChanged:(id)sender {
    [self checkIfCanAddNewCity];
}

-(NSString*)currentCityName{
    NSString *temp = self.city.name;
    NSRange range = [temp rangeOfString:@"(" options:NSLiteralSearch];
    if (range.location != NSNotFound){
        return [temp substringToIndex:range.location-1];
    }
    return temp;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    CAGradientLayer *bgLayer = [JDNClientHelper blueGradient];
    bgLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:bgLayer];
    [self.view bringSubviewToFront:self.cityName];
    [self.view bringSubviewToFront:self.url];
    [self.view bringSubviewToFront:self.nameLabel];
    [self.view bringSubviewToFront:self.urlLabel];
    [self checkIfCanAddNewCity];
    if ( !self.showUrl ) [self hideUrl];
    if ( self.city ){
        
        self.cityName.text = [self currentCityName];
        self.url.text = self.city.url;
        [self checkIfCanAddNewCity];
    }
    [self.cityName becomeFirstResponder];
}

@end