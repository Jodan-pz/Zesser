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

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSInteger nextTag = textField.tag + 1;
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        [nextResponder becomeFirstResponder];
    } else {
        if ( textField == self.url){
            [self addCity:textField];
            return YES;
        }else{
            [textField resignFirstResponder];
        }
    }
    return NO;
}

- (IBAction)cancelAddCity:(id)sender {
    if ( self.delegate){
        [self.delegate didAddedNewCity:nil
                          sender:self];
    }
}

- (IBAction)addCity:(id)sender {
    if ( self.delegate ){
        JDNCity *city = [[JDNCity alloc] init];
        city.name = self.city.text;
        city.url = self.url.text;
        [[JDNCities sharedCities] addCity:city];
        [self.delegate didAddedNewCity:city
                          sender:self];
    }
}

-(void)checkIfCanAddNewCity{
    self.okButton.enabled = NO;
    NSString *a = [self.city.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *b = [self.url.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.okButton.enabled = a.length && b.length;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)cityEditingChanged:(id)sender {
    [self checkIfCanAddNewCity];
}

- (IBAction)urlEditingChanged:(id)sender {
    [self checkIfCanAddNewCity];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self checkIfCanAddNewCity];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
