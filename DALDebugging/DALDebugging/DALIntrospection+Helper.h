//
//  DALIntrospection+Helper.h
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

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

extern NSString * const DALSwizzledPrefix;

#pragma mark Introspection Convenience
SEL DALSelectorForPropertyOfClass(objc_property_t property, Class aClass);
BOOL DALShouldIgnoreMethod(Method aMethod);
BOOL DALShouldIgnoreSelector(SEL selector);

#pragma mark Descriptions
NSString *DALDescriptionOfProtocolsForClass(Class aClass);
NSString *DALDescriptionOfReturnOrParameterType(const char *type);
NSString *DALDescriptionOfPropertyAttributeType(objc_property_attribute_t attribute);
NSString *DALDescriptionOfReturnValueFromMethod(id instance, Method aMethod); // Will ignore Methods that take parameters
NSString *DALDescriptionOfReturnValueForIvar(id instance, Ivar anIvar);
NSString *DALDescriptionOfFoundationObject(id instance);
NSString *DALDescriptionOfCoreFoundationObject(void *object);
NSString *DALDescriptionForUnsupportedType(const char *type);
NSString *DALDescriptionOfCATransform3D(CATransform3D transform3D);
NSString *DALBinaryRepresentationOfNSInteger(NSInteger anInteger);
NSString *DALBinaryRepresentationOfNSUInteger(NSUInteger anUnsignedInteger);

#pragma mark Swizzled Method Logging Convenience
id DALImplementationBlockForMethod(Method aMethod, SEL swizzledSelector, SEL originalSelector);
id DALBlockWithVoidReturnAndNumberOfArguments(unsigned numberOfArguments, SEL swizzledSelector, SEL originalSelector);
id DALBlockWithStructReturnAndNumberOfArguments(unsigned numberOfArguments, SEL swizzledSelector, SEL originalSelector);
id DALBlockWithIdReturnAndNumberOfArguments(unsigned numberOfArguments, SEL swizzledSelector, SEL originalSelector);
void DALRetainAutorelease(id instance);
char *DALCopyTypesForMethod(Method aMethod);

#endif
