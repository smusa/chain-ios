//
//  CNViewController.h
//  Hello Chain
//
//  Copyright (c) 2014 Chain. All rights reserved.
//

#import "CNAddressViewController.h"
#import <Chain/Chain.h>

@interface CNAddressViewController () <UITextFieldDelegate>
@end

@implementation CNAddressViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.addressField.text = @"1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG";
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateBalance];
}

- (IBAction)didEndEditing:(id)sender
{
    [self updateBalance];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

- (void) updateBalance
{
    [[Chain sharedInstance] getAddress:self.addressField.text
                     completionHandler:^(NSDictionary *dictionary, NSError *error) {
                         if(error) {
                             NSLog(@"Chain error: %@", error);
                             self.balanceField.text = error.localizedDescription ?: error.description ?: @"Error";
                         } else {
                             NSArray *result = [dictionary objectForKey:@"results"];
                             double balance = [[[[result firstObject] objectForKey:@"confirmed"] objectForKey:@"balance"] doubleValue];
                             float btc = balance / 100000000.0;

                            self.balanceField.text = [NSString stringWithFormat:@"%f BTC", btc];
                         }
                     }];
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}



@end
