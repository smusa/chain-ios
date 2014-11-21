//
//  CNViewController.m
//  Hello Chain
//
//  Copyright (c) 2014 Chain. All rights reserved.
//

#import "CNViewController.h"
#import <Chain/Chain.h>

@interface CNViewController ()
@property (nonatomic) IBOutlet UILabel* balanceLabel;
@end

@implementation CNViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [[Chain sharedInstance] getAddress:@"1A3tnautz38PZL15YWfxTeh8MtuMDhEPVB"
                     completionHandler:^(NSDictionary *dictionary, NSError *error) {
        if(error) {
            NSLog(@"Chain error: %@", error);
        } else {
            NSArray *result = [dictionary objectForKey:@"results"];
            double balance = [[[[result firstObject] objectForKey:@"balance"] objectForKey:@"confirmed"] doubleValue];
            float btc = balance / 100000000.0;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.balanceLabel setText:[NSString stringWithFormat:@"%f BTC", btc]];
            });
        }
    }];
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
