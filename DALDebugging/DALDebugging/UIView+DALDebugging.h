//
//  UIView+DALDebugging.h
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

/// \brief Notes: -description will append the View Controller if it has one.
@interface UIView (DALDebugging)

/// \brief Will create an image of the layer and save it to the Documents folder. Will append the current NSTimeInterval onto the name.
- (BOOL)saveToDocuments;
/// \brief The path to the Documents folder
- (NSString *)documentsPath;

/// \brief The View Controller that has this view as it's view.
/// \return If nil, the view is not a View Controller's view.
- (UIViewController *)viewController;

/// \brief Will traverse up the -nextResponder chain, asking each instance for the names of properties who's value is this object.
- (NSString *)propertyNames;

@end

#endif
