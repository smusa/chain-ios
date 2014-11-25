//
//  CNAppDelegate.m
//  Hello Chain
//
//  Copyright (c) 2014 Chain. All rights reserved.
//

#import "CNAppDelegate.h"
#import <Chain/Chain.h>

@implementation CNAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Chain sharedInstanceWithToken:@"2277e102b5d28a90700ff3062a282228"];
    
    self.window.rootViewController.view.tintColor = [UIColor colorWithHue:348.0/360.0 saturation:0.71 brightness:1.0 alpha:1.0];
    
    return YES;
}

@end
