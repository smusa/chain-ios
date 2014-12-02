//
//  CNViewController.h
//  Hello Chain
//
//  Copyright (c) 2014 Chain. All rights reserved.
//

#import "CNAddressViewController.h"
#import <Chain/Chain.h>
#import <CoreBitcoin/CoreBitcoin.h>

@interface CNAddressViewController () <UITextFieldDelegate>
@property(nonatomic) ChainNotificationObserver* addressObserver;
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
    [self updateObserver];
}

- (void) updateObserver
{
    [self.addressObserver disconnect];

    // Listen to new transactions on this address and update balance as needed.
    self.addressObserver = [[Chain sharedInstance] observerForNotification:
                            [[ChainNotification alloc] initWithAddress:self.addressField.text]
                                                             resultHandler:^(ChainNotificationResult *notification) {
                                                                 [self updateBalance];
                                                             }];
}

- (IBAction)didEndEditing:(id)sender
{
    [self updateObserver];
    [self updateBalance];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

- (void) updateBalance
{
    self.qrView.image = [BTCQRCode imageForString:self.addressField.text
                                             size:self.qrView.bounds.size
                                            scale:[UIScreen mainScreen].scale];

    [[Chain sharedInstance] getAddress:self.addressField.text
                     completionHandler:^(ChainAddressInfo* addressInfo, NSError *error) {
                         if (!addressInfo) {
                             NSLog(@"Chain error: %@", error);
                             [self showBalance:error.localizedDescription ?: error.description ?: @"Error"];
                         } else {
                             double balance = addressInfo.totalBalance;
                             float btc = balance / 100000000.0;

                             [self showBalance:[NSString stringWithFormat:@"%f BTC", btc]];
                         }
                     }];
}

- (void) showBalance:(NSString*)newBalance { // 👟
    if (![newBalance isEqualToString:self.balanceField.text]) {
        self.balanceField.text = newBalance;
        [self animateBalance];
    }
}

- (void) animateBalance
{
    [UIView animateWithDuration:0.1 animations:^{
        self.balanceField.transform = CGAffineTransformMakeScale(1.3, 1.3);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            self.balanceField.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
        }];
    }];
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}



@end
