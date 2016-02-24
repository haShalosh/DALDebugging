//
//  ApplePrivate.h
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

#import <UIKit/UIKit.h>

#if TARGET_OS_IPHONE && DEBUG

#if __IPHONE_7_0
@interface NSObject (DALApplePrivate_iOS7)

- (id)_ivarDescription NS_AVAILABLE_IOS(7_0);
- (id)_methodDescription NS_AVAILABLE_IOS(7_0);
- (id)_shortMethodDescription NS_AVAILABLE_IOS(7_0);

- (id)__ivarDescriptionForClass:(Class)aClass NS_AVAILABLE_IOS(7_0);
- (id)__methodDescriptionForClass:(Class)aClass NS_AVAILABLE_IOS(7_0);

@end
#endif

#pragma mark -
@interface UINib (DALApplePrivate)

- (id)effectiveBundle;
- (id)bundleResourcePath;

@end

#pragma mark -
@interface UIResponder (DALApplePrivate)

- (id)_nextViewControllerInResponderChain;

@end

#pragma mark -
@interface UIView (DALApplePrivate)

- (id)_gestureRecognizers;
- (id)_rootView;
- (id)_viewControllerForAncestor;
- (BOOL)isHiddenOrHasHiddenAncestor;
- (id)recursiveDescription;

@end

#pragma mark -
@interface UIViewController (DALApplePrivate)

- (id)nibName;
- (id)nibBundle;

@end

#pragma mark -
@interface UIWindow (DALApplePrivate)

+ (id)keyWindow;
- (id)representation;

@end

#endif
