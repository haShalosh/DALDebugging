//
//  UIControl+DALDebugging.h
//  DALDebugging
//
//  Created by Daniel Leber on 11/5/13.
//  Copyright (c) 2013 Daniel Leber. All rights reserved.
//

#if DEBUG

#import <UIKit/UIKit.h>

@interface UIControl (DALDebugging)

- (id)targetActions;

@end

#endif
