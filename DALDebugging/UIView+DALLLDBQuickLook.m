//
//  UIView+DALLLDBQuickLook.m
//  DALDebugging
//
//  Created by Daniel Leber on 10/8/14.
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

#import "UIView+DALLLDBQuickLook.h"
#import "NSObject+DALLLDBQuickLook.h"
#import "UIImage+DALDebugging.h"
#import "UIView+DALDebugging.h"

#if TARGET_OS_IPHONE && DEBUG

@implementation UIView (DALLLDBQuickLook)

- (NSData *)quickLookDebugData
{
	UIImage *image = [self DALDebugQuickLookObject];
	NSData *data = UIImagePNGRepresentation(image);
	return data;
}

- (NSString *)quickLookDebugFilename
{
	NSString *filename = [[super quickLookDebugFilename] stringByAppendingPathExtension:@"png"];
	return filename;
}


@end

#endif
