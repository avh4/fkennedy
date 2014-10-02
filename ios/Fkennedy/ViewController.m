//
//  ViewController.m
//  Fkennedy
//
//  Created by Aaron V. on 9/28/14.
//  Copyright (c) 2014 Aaron VonderHaar. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) NSArray *choices;
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.

  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"default"];

  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  NSLog(@"%@", self.tableView.dataSource);

  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://fkennedy.herokuapp.com/api/v1/testCards"]];
//  NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
  [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
    NSDictionary *round = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

    if (!round[@"card"]) return;
    NSURL *url = [NSURL URLWithString:round[@"card"][@"question"]];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    [self.imageView setImage:image];

    self.choices = round[@"choices"];
    [self.tableView reloadData];
}];

}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.choices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"default" forIndexPath:indexPath];

  cell.textLabel.text = self.choices[indexPath.row];

  return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://fkennedy.herokuapp.com/api/v1/reportScore?msisdn=%@&text=%@", [UIDevice currentDevice].identifierForVendor.UUIDString, self.choices[indexPath.row]]]];
  [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    NSLog(@"%ld", (long)httpResponse.statusCode);
  }];
}
@end
