//
//  DALTableViewController.m
//  DALDebuggingDemo
//
//  Created by Daniel Leber on 9/11/14.
//  Copyright (c) 2014 Daniel Leber. All rights reserved.
//

#import "DALTableViewController.h"
#import "DALTableViewCell.h"

static NSString * const DALTableViewCellIdentifier = @"DALTableViewCellIdentifier";

@interface DALTableViewController ()

@end

@implementation DALTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	UINib *nib = [UINib nibWithNibName:@"DALTableViewCell" bundle:nil];
	[self.tableView registerNib:nib forCellReuseIdentifier:DALTableViewCellIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DALTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DALTableViewCellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
	cell.memoryAddressLabel.text = [NSString stringWithFormat:@"%p", cell];
    
    return cell;
}

@end
