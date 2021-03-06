//
//  UIView+DALDebugging.m
//  DALDebugging
//
//  Created by Daniel Leber on 10/19/13.
//  Copyright (c) 2013 Daniel Leber. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import "UIView+DALDebugging.h"
#import "DALRuntimeModification.h"
#import "DALIntrospection.h"

#if TARGET_OS_IPHONE && DEBUG

@implementation UIView (DALDebugging)

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		DALSwizzleClassOriginalSelectorWithSwizzledSelector(self, @selector(description), @selector(DALSwizzledDescription));
		
		DALAddImplementationOfSelectorToSelectorIfNeeded(self, @selector(DALDebugQuickLookObject), @selector(debugQuickLookObject));
		DALAddImplementationOfSelectorToSelectorIfNeeded(self, @selector(DALViewController), @selector(viewController));
	});
}

- (NSString *)DALSwizzledDescription
{
	NSString *description = [self DALSwizzledDescription];
	
	UIViewController *viewController = [self DALViewController];
	if (viewController)
	{
		description = [description stringByAppendingFormat:@"; view controller: %@", viewController];
	}
	
	return description;
}

- (id)DALDebugQuickLookObject
{
	UIImage *image = nil;
	
	if (CGSizeEqualToSize(self.frame.size, CGSizeZero))
	{
		// The console will complain if nil is returned.
		image = [[UIImage alloc] init];
	}
	else
	{
		UIGraphicsBeginImageContext(self.frame.size);
		if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
		{
			[self drawViewHierarchyInRect:(CGRect){CGPointZero, self.bounds.size} afterScreenUpdates:NO];
		}
		else
		{
			[self.layer renderInContext:UIGraphicsGetCurrentContext()];
		}
		image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
	
	return image;
}

#pragma mark - Public

- (UIViewController *)DALViewController
{
	UIViewController *viewController = nil;
	
	id nextResponder = [self nextResponder];
	if ([nextResponder isKindOfClass:[UIViewController class]])
	{
		viewController = nextResponder;
	}
	
	return viewController;
}

@end

#endif
