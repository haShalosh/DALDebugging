//
//  UICollectionReusableView+DALDebugging.m
//  DALDebugging
//
//  Created by Daniel Leber on 9/11/14.
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

#import "UICollectionReusableView+DALDebugging.h"
#import "DALRuntimeModification.h"
#import "UINib+DALDebugging.h"

#if TARGET_OS_IPHONE && DEBUG

@implementation UICollectionReusableView (DALDebugging)

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		DALAddImplementationOfSelectorToSelectorIfNeeded(self, @selector(DALNibName), @selector(nibName));
	});
}

- (NSString *)DALNibName
{
	NSString *name = nil;
	
	id nextResponder = self;
	while ((nextResponder = [nextResponder nextResponder]))
	{
		if (![nextResponder isKindOfClass:[UICollectionView class]])
			continue;
		
		UICollectionView *collectionView = nextResponder;
		NSDictionary *cellNibDict = [collectionView valueForKey:@"_cellNibDict"];
		UINib *nib = cellNibDict[self.reuseIdentifier];
		name = [nib DALName];
		break;
	}
	
	return name;
}

@end

#endif