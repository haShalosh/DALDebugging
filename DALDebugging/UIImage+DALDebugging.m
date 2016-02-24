//
//  UIImage+DALDebugging.m
//  DALDebugging
//
//  Created by Daniel Leber on 10/8/14.
//  Copyright (c) 2014 Daniel Leber. All rights reserved.
//
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

#import "UIImage+DALDebugging.h"
#import "DALRuntimeModification.h"

#if TARGET_OS_IPHONE && DEBUG

void *DALDebuggingUIImageCreationDescriptionKey = &DALDebuggingUIImageCreationDescriptionKey;

@implementation UIImage (DALDebugging)

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		
	});
}

+ (UIImage *)DALImageNamed:(NSString *)name
{
	UIImage *image = [self DALImageNamed:(NSString *)name];
	
	NSString *creationDescription = [NSString stringWithFormat:@"name: %@", name];
	objc_setAssociatedObject(image, DALDebuggingUIImageCreationDescriptionKey, creationDescription, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	return image;
}

+ (UIImage *)DALImageNamed:(NSString *)name inBundle:(NSBundle *)bundle compatibleWithTraitCollection:(UITraitCollection *)traitCollection
{
	UIImage *image = [self DALImageNamed:(NSString *)name inBundle:(NSBundle *)bundle compatibleWithTraitCollection:(UITraitCollection *)traitCollection];
	
	NSString *creationDescription = [NSString stringWithFormat:@"name: %@; bundle: %@; traitCollection: %@", name, bundle, traitCollection];
	objc_setAssociatedObject(image, DALDebuggingUIImageCreationDescriptionKey, creationDescription, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	return image;
}

- (instancetype)DALInitWithContentsOfFile:(NSString *)path
{
	__typeof__(self) image = [self DALInitWithContentsOfFile:(NSString *)path];
	
	NSString *creationDescription = [NSString stringWithFormat:@"path: %@", path];
	objc_setAssociatedObject(image, DALDebuggingUIImageCreationDescriptionKey, creationDescription, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	return image;
}

- (NSString *)DALDescription
{
	NSString *string = [self DALDescription];
	
	NSString *creationDescription = objc_getAssociatedObject(self, DALDebuggingUIImageCreationDescriptionKey);
	if (creationDescription.length)
	{
		string = [string stringByAppendingFormat:@"; %@", creationDescription];
	}
	
	return string;
}

@end

#endif
