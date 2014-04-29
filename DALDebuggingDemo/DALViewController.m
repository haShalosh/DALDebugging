//
//  DALViewController.m
//  DALDebuggingDemo
//
//  Created by Daniel Leber on 4/27/14.
//  Copyright (c) 2014 Daniel Leber. All rights reserved.
//

#import "DALViewController.h"
#import "DALIntrospection.h"

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
	id ivarNames = DALInstanceIvarNamesInNextResponderChainOfInstance(self.view);
	id propertyNames = DALInstancePropertyNamesInNextResponderChainOfInstance(self.view);
	
	NSLog(@"");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
