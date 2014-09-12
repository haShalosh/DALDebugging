//
//  DALCollectionViewController.m
//  DALDebuggingDemo
//
//  Created by Daniel Leber on 9/11/14.
//  Copyright (c) 2014 Daniel Leber. All rights reserved.
//

#import "DALCollectionViewController.h"
#import "DALCollectionViewCell.h"

static NSString * const DALCollectionViewCellIdentifier = @"DALCollectionViewCellIdentifier";

@interface DALCollectionViewController ()

@end

@implementation DALCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	UINib *nib = [UINib nibWithNibName:@"DALCollectionViewCell" bundle:nil];
	
	NSArray *views = [nib instantiateWithOwner:nil options:nil];
	
	[self.collectionView registerNib:nib forCellWithReuseIdentifier:DALCollectionViewCellIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	DALCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DALCollectionViewCellIdentifier forIndexPath:indexPath];
	
	// Configure
	cell.memoryAddressLabel.text = [NSString stringWithFormat:@"%p", cell];
	
	return cell;
}

@end
