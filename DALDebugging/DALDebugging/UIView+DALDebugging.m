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

#if DEBUG

#import "UIView+DALDebugging.h"
#import "DALSwizzling.h"
#import "DALIntrospection+Helper.h"

@implementation UIView (DALDebugging)

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		DALSwizzleClassOriginalSelectorSwizzledSelector(self, @selector(description), @selector(DAL_description));
	});
}

- (NSString *)DAL_description
{
	NSString *description = [self DAL_description];
	
	UIViewController *viewController = [self viewController];
	if (viewController)
	{
		description = [description stringByAppendingFormat:@"; view controller: %@", viewController];
	}
	
	return description;
}

- (id)debugQuickLookObject
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

- (UIViewController *)viewController
{
	UIViewController *viewController = nil;
	
	id nextResponder = [self nextResponder];
	if ([nextResponder isKindOfClass:[UIViewController class]])
	{
		viewController = nextResponder;
	}
	
	return viewController;
}

- (NSString *)propertyNames
{
	NSMutableArray *propertyNames = [NSMutableArray array];
	
	UIResponder *nextResponder = [self nextResponder];
	while (nextResponder)
	{
		NSDictionary *nextResponderPropertyNamesAndObjectMemoryAddresses = DALPropertyNamesAndValuesMemoryAddressesForObject(nextResponder);
		
		NSString *theObject = [NSString stringWithFormat:@"%p", self];
		NSArray *nextResponderPropertyNames = [nextResponderPropertyNamesAndObjectMemoryAddresses allKeysForObject:theObject];
		for (NSString *propertyName in nextResponderPropertyNames)
		{
			[propertyNames addObject:propertyName];
		}
		
		nextResponder = [nextResponder nextResponder];
	}
	
	return [propertyNames description];
}

- (BOOL)saveToDocuments
{
	BOOL didSave = NO;
	
	UIImage *image = nil;
	
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
	
	NSData *data = UIImagePNGRepresentation(image);
	NSString *timestamp = [[NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]] stringValue];
	NSString *pathComponent = [[@"Documents/image-" stringByAppendingString:timestamp] stringByAppendingString:@".png"];
	NSString *file = [NSHomeDirectory() stringByAppendingPathComponent:pathComponent];
	didSave = [data writeToFile:file atomically:YES];
	
	return didSave;
}

- (NSString *)documentsPath
{
	NSString *documentsPath = [(NSString *)NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"];
	return documentsPath;
}

@end

#endif
