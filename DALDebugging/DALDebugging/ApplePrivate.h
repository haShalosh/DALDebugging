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

#if DEBUG

#import <UIKit/UIKit.h>

#if __IPHONE_7_0

@interface NSObject (DALApplePrivate_iOS7)

/// \return A description of all the ivars in the class and it's superclasses.
- (id)_ivarDescription NS_AVAILABLE_IOS(7_0);

/// \return A description of all the methods on the class and it's superclasses.
- (id)_methodDescription NS_AVAILABLE_IOS(7_0);

/// \return A description of all the methods on the class and it's superclasses, excluding Apple classes.
- (id)_shortMethodDescription NS_AVAILABLE_IOS(7_0);

- (id)__ivarDescriptionForClass:(Class)arg1;
- (id)__methodDescriptionForClass:(Class)arg1;

@end

#endif

#pragma mark -
@interface UINib (DALApplePrivate)

/// \brief The bundle resource name is accessible by -[self->storage bundleResourceName].
/// \return The bundle used to initialize the nib.
- (id)effectiveBundle;

/// \return The path to the nib on disk
- (id)bundleResourcePath;

@end

#pragma mark -
@interface UIResponder (DALApplePrivate)

/// \return The next view controller going up the responder chain
- (id)_nextViewControllerInResponderChain;

@end

#pragma mark -
@interface UIView (DALApplePrivate)

/// \return An array of the gesture recognizers.
- (id)_gestureRecognizers;

/// \brief Appears to be identical to -window.
/// \return An instance or subclass of UIView.
- (id)_rootView;

/// \return The first view controller going up the responder chain.
- (id)_viewControllerForAncestor;

/// \return A BOOL of whether the view, or one of it's ancestors, is hidden.
- (BOOL)isHiddenOrHasHiddenAncestor;

/// \return A text representation of the view hierarchy.
- (id)recursiveDescription;
@end

#pragma mark -
@interface UIViewController (DALApplePrivate)

/// \return The nib parameter used to initialize the view controller.
- (id)nibName;

/// \return The bundle parameter used to initialize the view controller.
- (id)nibBundle;

@end

#pragma mark -
@interface UIWindow (DALApplePrivate)

/// \return A JSON compatible representation of the view hierarchy.
- (id)representation;

@end

#endif
