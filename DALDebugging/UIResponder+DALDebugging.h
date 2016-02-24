//
//  UIResponder+DALDebugging.h
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

#import <UIKit/UIKit.h>

#if TARGET_OS_IPHONE && DEBUG

@interface UIResponder (DALDebugging)

/// \brief Travels the next responder chain, logging when the value of any if their Ivars is this instance.
- (NSString *)DALIvarNames;
/// \brief Travels the next responder chain, logging when the value of any if their Properties is this instance.
- (NSString *)DALPropertyNames;


/// \brief Travels the next responder chain looking for the first object that is, or a subclass of, the specified classes.
- (id)DAL_nextObjectOfClassInResponderChain:(NSArray *)classes; // An array of Classes.
// Convenience methods
- (UICollectionView *)DALNextCollectionViewInResponderChain;
- (UITableView *)DALNextTableViewInResponderChain;
- (id)DALNextCollectionOrTableViewInResponderChain;
- (id)DALNextCellInResponderChain; // UICollectionReusableView or UITableViewCell

// Convenience
- (NSString *)ivarNames;
- (NSString *)propertyNames;
- (UICollectionView *)nextCollectionViewInResponderChain;
- (UITableView *)nextTableViewInResponderChain;
- (id)nextCollectionOrTableViewInResponderChain;
- (id)nextCellInResponderChain;

@end

#endif
