//
//  CNViewController.h
//  Hello Chain
//
//  Copyright (c) 2014 Chain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CNNotificationsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end
