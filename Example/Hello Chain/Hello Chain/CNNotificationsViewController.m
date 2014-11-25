//
//  CNViewController.h
//  Hello Chain
//
//  Copyright (c) 2014 Chain. All rights reserved.
//

#import "CNNotificationsViewController.h"
#import <Chain/Chain.h>

@implementation CNNotificationsViewController {
    NSMutableArray* _items;
    ChainNotificationObserver* _observer;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startObserver];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopObserver];
}

- (void) startObserver
{
    if (!_observer)
    {
        __weak __typeof(self) weakself = self;
        _observer = [[Chain sharedInstance]
                     observerForNotifications:@[
                                                [[ChainNotification alloc] initWithType:ChainNotificationTypeNewTransaction],
                                                [[ChainNotification alloc] initWithType:ChainNotificationTypeNewBlock],

                                                ]
                     resultHandler:^(ChainNotificationResult *result) {
            if ([result.type isEqualToString:ChainNotificationTypeNewTransaction])
            {
                [weakself receivedItem:@{
                                         @"title": @"NEW TRANSACTION",
                                         @"detail": [result.payloadDictionary[@"transaction"] objectForKey:@"hash"],
                                         @"txhash": [result.payloadDictionary[@"transaction"] objectForKey:@"hash"],
                                         }];
            }
            else if ([result.type isEqualToString:ChainNotificationTypeNewBlock])
            {
                [weakself receivedItem:@{
                                         @"title": @"NEW BLOCK",
                                         @"detail": [result.payloadDictionary[@"block"] objectForKey:@"hash"],
                                         }];
            }
        }];

        _observer.disconnectHandler = ^(BOOL ok, NSError* error) {
            __typeof(self) strongself = weakself;
            if (strongself) {
                strongself->_observer = nil;

                [weakself receivedItem:@{
                                         @"title": @"WEBSOCKET DISCONNECTED",
                                         @"detail": error.localizedDescription ?: @"",
                                         }];
            }
        };

        [self receivedItem:@{
                                 @"title": @"STARTED",
                                 @"detail": @"Listening for new blocks and transactions...",
                                 }];

    }
}

- (void) stopObserver
{
    [_observer disconnect];
    _observer = nil;

    [self receivedItem:@{
                             @"title": @"STOPPED",
                             @"detail": @"Not listening while not visible.",
                             }];

}

- (void) receivedItem:(NSDictionary*)item
{
    _items = _items ?: [NSMutableArray array];
    [_items insertObject:item atIndex:0];

    if (_items.count <= 1)
    {
        [self.tableView reloadData];
    }
    else
    {
        [self.tableView beginUpdates];
        NSIndexPath* ip = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[ ip ] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    }
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSDictionary* item = _items[indexPath.row];
    cell.textLabel.text = item[@"title"];
    cell.detailTextLabel.text = item[@"detail"];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary* item = _items[indexPath.row];

    if (item[@"txhash"])
    {
        // http://explorer.chain.com/transactions/3cd63b3a48551701bf8bd52e74debb17195aaa0879d1eb79484621f2f9120971
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://explorer.chain.com/transactions/%@", item[@"txhash"]]]];
    }
}


@end
