//
//  DALRuntimeModification.h
//  DALDebugging
//
//  Created by Daniel Leber on 4/26/14.
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
//  Reference: http://nshipster.com/method-swizzling/
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#if DEBUG

static inline void DALAddImplementationOfSelectorToSelectorIfNeeded(Class aClass, SEL implementedSelector, SEL toSelector)
{
	Method implementedMethod = class_getInstanceMethod(aClass, implementedSelector);
	Method toMethod = class_getInstanceMethod(aClass, toSelector);
	if (toMethod == nil)
	{
		class_addMethod(aClass, toSelector, method_getImplementation(implementedMethod), method_getTypeEncoding(implementedMethod));
	}
}

static inline void DALSwizzleClassOriginalSelectorWithSwizzledSelector(Class aClass, SEL originalSelector, SEL swizzledSelector)
{
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

#endif
