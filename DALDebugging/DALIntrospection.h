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

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#if DEBUG

#pragma mark Class
OBJC_EXPORT id DALClassIvarDescription(Class aClass);
OBJC_EXPORT id DALClassMethodDescription(Class aClass);
OBJC_EXPORT id DALClassShortMethodDescription(Class aClass);

#pragma mark Instance
OBJC_EXPORT id DAL_ivarDescription(id instance);
OBJC_EXPORT id DAL_methodDescription(id instance);
OBJC_EXPORT id DAL_shortMethodDescription(id instance);

OBJC_EXPORT id DAL__ivarDescriptionForClass(id instance, Class aClass);
OBJC_EXPORT id DAL__methodDescriptionForClass(id instance, Class aClass);

#endif
