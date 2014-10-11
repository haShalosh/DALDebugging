//
//  UIResponder+DALDebugging.m
//  DALDebugging
//
//  Created by Daniel Leber on 7/28/14.
//  Copyright (c) 2014 Daniel Leber. All rights reserved.
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

#if TARGET_OS_IPHONE && DEBUG

#import "UIResponder+DALDebugging.h"
#import "DALRuntimeModification.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation UIResponder (DALDebugging)

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		DALAddImplementationOfSelectorToSelectorIfNeeded(self, @selector(DALIvarNames), @selector(ivarNames));
		DALAddImplementationOfSelectorToSelectorIfNeeded(self, @selector(DALPropertyNames), @selector(propertyNames));
		DALAddImplementationOfSelectorToSelectorIfNeeded(self, @selector(DALNextCollectionViewInResponderChain), @selector(nextCollectionViewInResponderChain));
		DALAddImplementationOfSelectorToSelectorIfNeeded(self, @selector(DALNextTableViewInResponderChain), @selector(nextTableViewInResponderChain));
		DALAddImplementationOfSelectorToSelectorIfNeeded(self, @selector(DALNextCollectionOrTableViewInResponderChain), @selector(nextCollectionOrTableViewInResponderChain));
		DALAddImplementationOfSelectorToSelectorIfNeeded(self, @selector(DALNextCellInResponderChain), @selector(nextCellInResponderChain));
	});
}

- (id)DALIvarNames
{
	NSMutableString *description = [NSMutableString string];
	
	[description appendFormat:@"<%@: %p> in Ivars:\n", NSStringFromClass([self class]), self];
	
	id nextResponder = [self nextResponder];
	while (nextResponder)
	{
		Class aClass = [nextResponder class];
		while (aClass)
		{
			unsigned int count = 0;
			Ivar *list = class_copyIvarList(aClass, &count);
			for (unsigned int i = 0; i < count; i++)
			{
				Ivar anIvar = list[i];
				
				const char *typeEncoding = ivar_getTypeEncoding(anIvar);
				if (typeEncoding[0] == _C_ID)
				{
					id value = nil;
					@try
					{
						value = object_getIvar(nextResponder, anIvar);
					}
					@catch (NSException *exception)
					{
#if DAL_DEBUGGING_DEMO
						NSLog(@"Error! %@", exception);
#endif
					}
					
					if (value == self)
					{
						NSString *key = @(ivar_getName(anIvar));
						[description appendFormat:@"\t'%@' in <%@: %p> (declared in class: %@)\n", key, NSStringFromClass([nextResponder class]), nextResponder, NSStringFromClass(aClass)];
					}
				}
			}
			
			if (list)
			{
				free(list);
			}
			
			aClass = [aClass superclass];
		}
		
		nextResponder = [nextResponder nextResponder];
	}
	
	return description;
}

- (id)DALPropertyNames
{
	NSMutableString *description = [NSMutableString string];
	
	[description appendFormat:@"<%@: %p> in Properties:\n", NSStringFromClass([self class]), self];
	
	id nextResponder = [self nextResponder];
	while (nextResponder)
	{
		Class aClass = [nextResponder class];
		while (aClass)
		{
			unsigned int count = 0;
			objc_property_t *list = class_copyPropertyList(aClass, &count);
			for (unsigned int i = 0; i < count; i++)
			{
				objc_property_t aProperty = list[i];
				
				char *attributeValueType = property_copyAttributeValue(aProperty, "T");
				if (attributeValueType[0] == _C_ID)
				{
					NSString *key = @(property_getName(aProperty));
					
					char *getter = property_copyAttributeValue(aProperty, "G");
					if (getter)
					{
						key = @(getter);
						
						free(getter);
					}
					
					id value = nil;
					@try
					{
						SEL selector = NSSelectorFromString(key);
						if ([nextResponder respondsToSelector:selector])
						{
							value = ((id (*)(id, SEL))objc_msgSend)(nextResponder, selector);
						}
					}
					@catch (NSException *exception)
					{
#if DAL_DEBUGGING_DEMO
						NSLog(@"Error! %@", exception);
#endif
					}
					
					if (value == self)
					{
						[description appendFormat:@"\t'%@' in <%@: %p> (declared in class: %@)\n", key, NSStringFromClass([nextResponder class]), nextResponder, NSStringFromClass(aClass)];
					}
				}
				
				if (attributeValueType)
				{
					free(attributeValueType);
				}
			}
			
			if (list)
			{
				free(list);
			}
			
			aClass = [aClass superclass];
		}
		
		nextResponder = [nextResponder nextResponder];
	}
	
	return description;
}

- (id)DAL_nextObjectOfClassInResponderChain:(NSArray *)classes
{
	id object = nil;
	
	UIResponder *nextResponder = self;
	while ((nextResponder = [nextResponder nextResponder]))
	{
		for (Class aClass in classes)
		{
			if ([nextResponder isKindOfClass:aClass])
			{
				object = nextResponder;
				break;
			}
		}
	}
	
	return object;
}

- (UICollectionView *)DALNextCollectionViewInResponderChain
{
	return [self DAL_nextObjectOfClassInResponderChain:@[[UICollectionView class]]];
}

- (UITableView *)DALNextTableViewInResponderChain
{
	return [self DAL_nextObjectOfClassInResponderChain:@[[UITableView class]]];
}

- (id)DALNextCollectionOrTableViewInResponderChain
{
	return [self DAL_nextObjectOfClassInResponderChain:@[[UICollectionView class], [UITableView class]]];
}

- (id)DALNextCellInResponderChain
{
	return [self DAL_nextObjectOfClassInResponderChain:@[[UICollectionReusableView class], [UITableViewCell class]]];
}

@end

#endif
