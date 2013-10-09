//
//  DALDebugging
//  UIView+DALIntrospection.m
//
//  Created by Daniel Leber, 2013.
//

#if DEBUG

#import "UIView+DALIntrospection.h"
#import <objc/runtime.h>

@implementation UIView (DALIntrospection)

+ (void)load
{
	Method m1 = class_getInstanceMethod([self class], @selector(description));
	Method m2 = class_getInstanceMethod([self class], @selector(DAL_description));
	method_exchangeImplementations(m1, m2);
}

- (NSString *)DAL_description
{
	NSString *description = [self DAL_description];
	
	id nextResponder = [self nextResponder];
	if ([nextResponder isKindOfClass:[UIViewController class]])
	{
		UIViewController *viewController = nextResponder;
		description = [description stringByAppendingFormat:@"; view controller: %@", viewController];
	}
	
	return description;
}

@end

#endif
