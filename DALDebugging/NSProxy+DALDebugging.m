//
//  NSProxy+DALDebugging.m
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

#import "NSProxy+DALDebugging.h"
#import "DALIntrospection.h"
#import "DALRuntimeModification.h"

@implementation NSProxy (DALDebugging)

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		DALAddImplementationOfSelectorToSelectorIfNeeded(self, @selector(DAL_ivarDescription),				@selector(_ivarDescription));
		DALAddImplementationOfSelectorToSelectorIfNeeded(self, @selector(DAL_methodDescription),			@selector(_methodDescription));
		DALAddImplementationOfSelectorToSelectorIfNeeded(self, @selector(DAL_shortMethodDescription),		@selector(_shortMethodDescription));
		DALAddImplementationOfSelectorToSelectorIfNeeded(self, @selector(DAL__ivarDescriptionForClass:),	@selector(__ivarDescriptionForClass:));
		DALAddImplementationOfSelectorToSelectorIfNeeded(self, @selector(DAL__methodDescriptionForClass:),	@selector(__methodDescriptionForClass:));
	});
}

- (id)DAL_ivarDescription
{
	return DAL_ivarDescription(self);
}

- (id)DAL_methodDescription
{
	return DAL_methodDescription(self);
}

- (id)DAL_shortMethodDescription
{
	return DAL_shortMethodDescription(self);
}

- (id)DAL__ivarDescriptionForClass:(Class)aClass
{
	return DAL__ivarDescriptionForClass(self, aClass);
}

- (id)DAL__methodDescriptionForClass:(Class)aClass
{
	return DAL__methodDescriptionForClass(self, aClass);
}

@end

#endif
