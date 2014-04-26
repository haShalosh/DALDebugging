//
//  DALSwizzling.h
//  DALDebugging
//
//  Created by Daniel Leber on 4/26/14.
//  Copyright (c) 2014 Daniel Leber. All rights reserved.
//
//  Reference: http://nshipster.com/method-swizzling/
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

static inline void DALSwizzleClassOriginalSelectorSwizzledSelector(Class aClass, SEL originalSelector, SEL swizzledSelector)
{
	// When swizzling a class method, use the following:
	// Class class = object_getClass((id)self);
	
	Method originalMethod = class_getInstanceMethod(aClass, originalSelector);
	Method swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector);
	
	BOOL didAddMethod = class_addMethod(aClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
	if (didAddMethod)
	{
		class_replaceMethod(aClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
	}
	else
	{
		method_exchangeImplementations(originalMethod, swizzledMethod);
	}
}