//
//  DALTableViewCell.m
//  DALDebugging
//
//  Created by Daniel Leber on 10/19/13.
//  Copyright (c) 2013 Daniel Leber. All rights reserved.
//

#import "DALTableViewCell.h"

NSString * const DALTableViewCellIdentifier = @"DALTableViewCellIdentifier";

@implementation DALTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - IBAction

- (IBAction)didTapMyCellsButton:(UIButton *)button
{
	NSLog(@"%@", NSStringFromSelector(_cmd));
}

@end
