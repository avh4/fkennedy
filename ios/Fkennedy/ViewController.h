//
//  ViewController.h
//  Fkennedy
//
//  Created by Aaron V. on 9/28/14.
//  Copyright (c) 2014 Aaron VonderHaar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

