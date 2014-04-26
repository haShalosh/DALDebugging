//
//  DALIntrospection.h
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

#pragma mark - Class Introspection
NSString *DALClassAncestryWithProtocolsDescription(Class aClass, BOOL withProtocols);

NSString *DALClassIvarsDescription(Class aClass);
NSString *DALClassMethodsDescription(Class aClass);
NSString *DALClassPropertiesDescription(Class aClass);

#pragma mark Instance Introspection
NSString *DALInstanceIvarsDescription(id instance);
NSString *DALInstanceMethodsDescription(id instance);
NSString *DALInstancePropertiesDescription(id instance);

#pragma mark Protocol Introspection
NSString *DALProtocolDescription(Protocol *aProtocol); // Not yet implemented...


#pragma mark - Convenience
/// \brief This is equivalent to calling [[[UIApplication sharedApplication] keyWindow] recursiveDescription];
NSString *KeyWindowDescription(void);


#pragma mark - Swizzling Introspection
/// \brief This will swizzle all instance methods for the specifiec class. Note: This is a work-in-progress and _will_ crash your app!
void DALSwizzleInstanceMethodsForClass(Class aClass);

#endif
