//
//  DALViewController.m
//  DALDebuggingDemo
//
//  Created by Daniel Leber on 4/27/14.
//  Copyright (c) 2014 Daniel Leber. All rights reserved.
//

#import "DALViewController.h"
#import "UIResponder+DALDebugging.h"

@interface DALViewController ()

@end

@implementation DALViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	// Testing getting ivar and property names
	id ivarNames = [self.firstButton DALIvarNames];
	id propertyNames = [self.firstButton DALPropertyNames];
	
	NSLog(@"self.view ivar names:\n%@\n", ivarNames);
	NSLog(@"self.view property names:\n%@\n", propertyNames);
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
