//
//  DALTableViewCell.h
//  DALDebugging
//
//  Created by Daniel Leber on 10/19/13.
//  Copyright (c) 2013 Daniel Leber. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const DALTableViewCellIdentifier;

@interface DALTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIView *gradientView;
@property (nonatomic, weak) IBOutlet UIImageView *myCellsImageView;
@property (nonatomic, weak, getter = myCustomButtonGetter) IBOutlet UIButton *myCellsButton;
@property (nonatomic, weak) IBOutlet UILabel *myCellsLabel;

- (IBAction)didTapMyCellsButton:(UIButton *)button;

@end
