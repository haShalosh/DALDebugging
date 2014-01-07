//
//  UIControl+DALDebugging.m
//  DALDebugging
//
//  Created by Daniel Leber on 11/5/13.
//  Copyright (c) 2013 Daniel Leber. All rights reserved.
//

#if DEBUG

#import "UIControl+DALDebugging.h"
#import <objc/runtime.h>

@implementation UIControl (DALDebugging)

- (id)targetActions;
{
    id targetActions = nil;
    
    Ivar anIvar = class_getInstanceVariable([UIControl class], "_targetActions");
    if (anIvar)
    {
        targetActions = object_getIvar(self, anIvar);
    }
    
    return targetActions;
}

@end

#endif
