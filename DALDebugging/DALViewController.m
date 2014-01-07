//
//  DALViewController.m
//  DALDebugging
//
//  Created by Daniel Leber on 10/19/13.
//  Copyright (c) 2013 Daniel Leber. All rights reserved.
//

#import "DALViewController.h"
#import "DALTableViewCell.h"
#import "NSObject+DALDebugging.h"
#import "UIView+DALDebugging.h"

@interface DALViewController ()

@end

@implementation DALViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
	NSLog(@"How the find the property names of a label"
		  "\nIn the console, type: po KeyWindowDescription()"
		  "\nNow do a search for: My Cell's Label"
		  "\n(if you're wanting to find a view, you could search for it's frame)"
		  "\nGrab the memory address of the label."
		  "\nNow type: po [0xMEMORY_ADDRESS propertyNames]"
		  "\nCopy the class name, press COMMAND+SHIFT+O, paste in the class name, and open the header."
		  "\n\n");
	NSLog(@"");
	NSLog(@"Other neat things you can do:");
	NSLog(@"po [self.view ivarsDescription]:\n%@\n", [self.view ivarsDescription]);
	
    
    UIButton *button = [[UIButton alloc] init];
    [button addTarget:self action:@selector(controlEventTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(controlEventTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    NSLog(@"%@", button);
}

- (void)controlEventTouchUpInside:(UIControl *)control
{
    
}

- (void)controlEventTouchUpOutside:(UIControl *)control
{
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	DALTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DALTableViewCellIdentifier];
	[cell.myCellsButton propertyNames];
	return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 98.0;
}

@end
