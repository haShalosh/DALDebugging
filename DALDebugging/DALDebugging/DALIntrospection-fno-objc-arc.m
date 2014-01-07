//
//  DALIntrospection-fno-objc-arc.m
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

#import "DALIntrospection.h"
#import "DALIntrospection+Helper.h"
#import <objc/message.h>
#import <objc/runtime.h>

#if __has_feature(objc_arc)
#error Error! This class does not support ARC. Disable with: -fno-objc-arc
#endif

/// \brief Will ignore Methods that take parameters
NSString *DALDescriptionOfReturnValueFromMethod(id instance, Method aMethod)
{
	SEL selector = method_getName(aMethod);
	
	int returnTypeLength = 1024 * 10;
	char returnTypeChar[returnTypeLength];
	
	method_getReturnType(aMethod, returnTypeChar, returnTypeLength);
	
	u_int numberOfArguments = method_getNumberOfArguments(aMethod);
	if (numberOfArguments > 2)
		return @"(ignored)";
	
	NSString *description = nil;
	switch (returnTypeChar[0])
	{
		case _C_ID:       // '@'
		{
			id result = nil;
			result = objc_msgSend(instance, selector);
			description = DALDescriptionOfFoundationObject(result);
		}
			break;
			
		case _C_CLASS:    // '#'
		{
			Class result = NULL;
			result = (Class)objc_msgSend(instance, selector);
			if (result)
				description = NSStringFromClass(result);
			else
				description = [NSString stringWithFormat:@"*** Error! Unable to get class from '%@' for selector: %@.", instance, NSStringFromSelector(selector)];
		}
			break;
			
		case _C_SEL:      // ':'
		{
			SEL result = NULL;
			result = (SEL)objc_msgSend(instance, selector);
			description = NSStringFromSelector(result);
		}
			break;
			
		case _C_UCHR:     // 'C'
		{
			unsigned char result = 0;
			result = (unsigned char)objc_msgSend(instance, selector);
			description = [NSString stringWithFormat:@"%hhu", result];
		}
			break;
			
		case _C_SHT:      // 's'
		{
			short result = 0;
			result = (short)objc_msgSend(instance, selector);
			description = [NSString stringWithFormat:@"%hd", result];
		}
			break;
			
		case _C_USHT:     // 'S'
		{
			unsigned short result = 0;
			result = (unsigned short)objc_msgSend(instance, selector);
			description = [NSString stringWithFormat:@"%hu", result];
		}
			break;
			
		case _C_INT:      // 'i'
		{
			int result = 0;
			result = (int)objc_msgSend(instance, selector);
			description = [NSString stringWithFormat:@"%d", result];
		}
			break;
			
		case _C_UINT:     // 'I'
		{
			unsigned int result = 0;
			result = (unsigned int)objc_msgSend(instance, selector);
			description = [NSString stringWithFormat:@"%u", result];
		}
			break;
			
		case _C_LNG:      // 'l'
		{
			long result = 0;
			result = (long)objc_msgSend(instance, selector);
			description = [NSString stringWithFormat:@"%ld", result];
		}
			break;
			
		case _C_ULNG:     // 'L'
		{
			unsigned long result = 0;
			result = (unsigned long)objc_msgSend(instance, selector);
			description = [NSString stringWithFormat:@"%lu", result];
		}
			break;
			
		case _C_LNG_LNG:  // 'q'
		{
			long long result = 0;
			result = (long long)objc_msgSend(instance, selector);
			description = [NSString stringWithFormat:@"%lld", result];
		}
			break;
			
		case _C_ULNG_LNG: // 'Q'
		{
			unsigned long long result = 0;
			result = (unsigned long long)objc_msgSend(instance, selector);
			description = [NSString stringWithFormat:@"%llu", result];
		}
			break;
			
		case _C_FLT:      // 'f'
        {
			float result = 0;
#if TARGET_IPHONE_SIMULATOR
			result = objc_msgSend_fpret(instance, selector, NULL);
			description = [NSString stringWithFormat:@"%f", result];
#else
			DALInvokeMethodForResult(instance, aMethod, &result);
			description = [NSString stringWithFormat:@"%f", result];
#endif
        }
			break;
			
		case _C_DBL:      // 'd'
        {
			double result = 0;
#if TARGET_IPHONE_SIMULATOR
			result = objc_msgSend_fpret(instance, selector, NULL);
			description = [NSString stringWithFormat:@"%f", result];
#else
			DALInvokeMethodForResult(instance, aMethod, &result);
			description = [NSString stringWithFormat:@"%f", result];
#endif
        }
			break;
			
		case _C_BFLD:     // 'b'
		{
			NSUInteger result;
			result = (NSUInteger)objc_msgSend(instance, selector);
			description = DALBinaryRepresentationOfNSUInteger(result);
		}
			break;
			
		case _C_CHR:      // 'c' // BOOL is usually type'd as a char
		case _C_BOOL:     // 'B'
		{
			BOOL result = NO;
			result = (BOOL)objc_msgSend(instance, selector);
			description = (result ? @"YES" : @"NO");
		}
			break;
			
		case _C_VOID:     // 'v'
			description = @"(void)";
			break;
			
		case _C_UNDEF:    // '?'
			description = @"(undefined)";
			break;
			
		case _C_PTR:      // '^'
		{
			switch (returnTypeChar[1])
			{
				case '{':
				{
                    NSString *returnType = [NSString stringWithUTF8String:returnTypeChar];
					if ([returnType hasPrefix:@"^{CGColor="])
					{
						CGColorRef result = NULL;
						DALInvokeMethodForResult(instance, aMethod, &result);
						description = [NSString stringWithFormat:@"%@", result];
					}
				}
					break;
					
				case 'v':
				{
					void *result = NULL;
					DALInvokeMethodForResult(instance, aMethod, &result);
					description = @"(TODO Implemented determining type for void *)";
				}
					break;
					
				default:
					description = DALDescriptionForUnsupportedType(returnTypeChar);
					break;
			}
		}
			break;
			
		case _C_CHARPTR:  // '*'
			description = DALDescriptionForUnsupportedType(returnTypeChar);
			break;
			
		case _C_ATOM:     // '%'
			description = DALDescriptionForUnsupportedType(returnTypeChar);
			break;
			
		case _C_ARY_B:    // '['
			description = DALDescriptionForUnsupportedType(returnTypeChar);
			break;
			
		case _C_ARY_E:    // ']'
			description = DALDescriptionForUnsupportedType(returnTypeChar);
			break;
			
		case _C_UNION_B:  // '('
			description = DALDescriptionForUnsupportedType(returnTypeChar);
			break;
			
		case _C_UNION_E:  // ')'
			description = DALDescriptionForUnsupportedType(returnTypeChar);
			break;
			
		case _C_STRUCT_B: // '{'
		{
			NSString *typeString = [NSString stringWithUTF8String:returnTypeChar];
			if ([typeString isEqualToString:@"{CGPoint=ff}"])
			{
				CGPoint result = CGPointZero;
				DALInvokeMethodForResult(instance, aMethod, &result);
				description = NSStringFromCGPoint(result);
			}
			else if ([typeString isEqualToString:@"{CGSize=ff}"])
			{
				CGSize result = CGSizeZero;
				DALInvokeMethodForResult(instance, aMethod, &result);
				description = NSStringFromCGSize(result);
			}
			else if ([typeString isEqualToString:@"{CGRect={CGPoint=ff}{CGSize=ff}}"])
			{
				CGRect result = CGRectZero;
				DALInvokeMethodForResult(instance, aMethod, &result);
				description = NSStringFromCGRect(result);
			}
			else if ([typeString isEqualToString:@"{UIEdgeInsets=ffff}"])
			{
				UIEdgeInsets result = UIEdgeInsetsZero;
				DALInvokeMethodForResult(instance, aMethod, &result);
				description = NSStringFromUIEdgeInsets(result);
			}
			else if ([typeString isEqualToString:@"{CGAffineTransform=ffffff}"])
			{
				CGAffineTransform result = CGAffineTransformMake(0, 0, 0, 0, 0, 0);;
				DALInvokeMethodForResult(instance, aMethod, &result);
				description = NSStringFromCGAffineTransform(result);
			}
			else
			{
				description = DALDescriptionForUnsupportedType(returnTypeChar);
			}
		}
			break;
			
		case _C_STRUCT_E: // '}'
			description = DALDescriptionForUnsupportedType(returnTypeChar);
			break;
			
		case _C_VECTOR:   // '!'
			description = DALDescriptionForUnsupportedType(returnTypeChar);
			break;
			
		case _C_CONST:    // 'r'
		{
			const char *result = NULL;
			result = (const char *)objc_msgSend(instance, selector);
			description = [NSString stringWithUTF8String:result];
		}
			break;
			
		default:
			description = [NSString stringWithFormat:@"Warning! Unexpected return type: %s", returnTypeChar];
			NSLog(@"*** %@", description);
			break;
	}
	
	return description;
}

NSString *DALDescriptionForUnsupportedType(const char *type)
{
	return [NSString stringWithFormat:@"Description not ypet implemented for: %s", type];
}

NSString *DALDescriptionOfFoundationObject(id instance)
{
	NSString *description = nil;
	
	if (instance)
	{
		if ([instance conformsToProtocol:@protocol(NSObject)])
		{
			description = [(NSObject *)instance description];
		}
		else
		{
			description = [NSString stringWithFormat:@"Object at memory address %p doesn't conform to NSObject protocol.", instance];
		}
	}
	else
	{
		description = @"nil";
	}
	
	return description;
}

NSString *DALDescriptionOfCoreFoundationObject(void *object)
{
	NSString *description = nil;
	
	if (object)
	{
		description = [NSString stringWithFormat:@"Description of Core Foundation object at memory address %p isn't yet implemented.", object];
	}
	else
	{
		description = @"nil";
	}
	
	return description;
}

NSString *DALDescriptionOfReturnValueForIvar(id instance, Ivar anIvar)
{
	NSString *description = nil;
	
	const char *name = ivar_getName(anIvar);
	const char *type = ivar_getTypeEncoding(anIvar);
	switch (type[0])
	{
		case _C_ID:       // '@'
		{
			id result = nil;
			result = object_getIvar(instance, anIvar);
			description = DALDescriptionOfFoundationObject(result);
		}
			break;
			
		case _C_CLASS:    // '#'
		{
			Class result = NULL;
			result = (Class)object_getIvar(instance, anIvar);
			if (result)
				description = NSStringFromClass(result);
			else
				description = @"nil";
		}
			break;
			
		case _C_SEL:      // ':'
		{
			SEL result = NULL;
			result = (SEL)object_getIvar(instance, anIvar);
			description = NSStringFromSelector(result);
		}
			break;
			
		case _C_UCHR:     // 'C'
		{
			unsigned char result = 0;
			result = (unsigned char)object_getIvar(instance, anIvar);
			description = [NSString stringWithFormat:@"%hhu", result];
		}
			break;
			
		case _C_SHT:      // 's'
		{
			short result = 0;
			result = (short)object_getIvar(instance, anIvar);
			description = [NSString stringWithFormat:@"%hd", result];
		}
			break;
			
		case _C_USHT:     // 'S'
		{
			unsigned short result = 0;
			result = (unsigned short)object_getIvar(instance, anIvar);
			description = [NSString stringWithFormat:@"%hu", result];
		}
			break;
			
		case _C_INT:      // 'i'
		{
			int result = 0;
			result = (int)object_getIvar(instance, anIvar);
			description = [NSString stringWithFormat:@"%d", result];
		}
			break;
			
		case _C_UINT:     // 'I'
		{
			unsigned int result = 0;
			result = (unsigned int)object_getIvar(instance, anIvar);
			description = [NSString stringWithFormat:@"%u", result];
		}
			break;
			
		case _C_LNG:      // 'l'
		{
			long result = 0;
			result = (long)object_getIvar(instance, anIvar);
			description = [NSString stringWithFormat:@"%ld", result];
		}
			break;
			
		case _C_ULNG:     // 'L'
		{
			unsigned long result = 0;
			result = (unsigned long)object_getIvar(instance, anIvar);
			description = [NSString stringWithFormat:@"%lu", result];
		}
			break;
			
		case _C_LNG_LNG:  // 'q'
		{
			long long result = 0;
			result = (long long)object_getIvar(instance, anIvar);
			description = [NSString stringWithFormat:@"%lld", result];
		}
			break;
			
		case _C_ULNG_LNG: // 'Q'
		{
			unsigned long long result = 0;
			result = (unsigned long long)object_getIvar(instance, anIvar);
			description = [NSString stringWithFormat:@"%llu", result];
		}
			break;
			
		case _C_FLT:      // 'f'
        {
			float result = 0;
			object_getInstanceVariable(instance, name, (void *)&result);
			description = [NSString stringWithFormat:@"%f", result];
        }
			break;
			
		case _C_DBL:      // 'd'
        {
			double result = 0;
			object_getInstanceVariable(instance, name, (void *)&result);
			description = [NSString stringWithFormat:@"%f", result];
        }
			break;
			
		case _C_BFLD:     // 'b'
		{
			//			void *result;
			//			result = (void *)object_getIvar(object, anIvar);
			description = [NSString stringWithFormat:@"bitfield result is currently unsupported"];
		}
			break;
			
		case _C_CHR:      // 'c' // BOOL is usually type'd as a char
		case _C_BOOL:     // 'B'
		{
			BOOL result = NO;
			result = (BOOL)object_getIvar(instance, anIvar);
			description = (result ? @"YES" : @"NO");
		}
			break;
			
		case _C_VOID:     // 'v'
			description = @"(void)";
			break;
			
		case _C_UNDEF:    // '?'
			description = @"(undefined)";
			break;
			
		case _C_PTR:      // '^'
		{
			switch (type[1])
			{
				case '{':
				{
					NSString *typeString = [NSString stringWithUTF8String:type];
					if ([typeString isEqualToString:@"^{CGColor=}"])
					{
						CGColorRef result = NULL;
						object_getInstanceVariable(instance, name, (void *)&result);
						UIColor *color = [UIColor colorWithCGColor:result];
						description = DALDescriptionOfFoundationObject(color);
					}
					else if ([typeString isEqualToString:@"^{__CFDictionary=}"])
					{
						CFDictionaryRef result = NULL;
						object_getInstanceVariable(instance, name, (void *)&result);
						description = DALDescriptionOfCoreFoundationObject((void *)result);
					}
					else
					{
						NSLog(@"***");
					}
				}
					break;
					
				case 'v':
				{
					void *result;
					result = (void *)object_getIvar(instance, anIvar);
					description = [NSString stringWithFormat:@"%p", result];
				}
					break;
					
				default:
					description = DALDescriptionForUnsupportedType(type);
					break;
			}
		}
			break;
			
		case _C_CHARPTR:  // '*'
        {
#warning TODO: Test this
            char *result;
			result = (char *)object_getIvar(instance, anIvar);
			description = [NSString stringWithUTF8String:result];
        }
			break;
			
		case _C_ATOM:     // '%'
			description = DALDescriptionForUnsupportedType(type);
			break;
			
		case _C_ARY_B:    // '['
			description = DALDescriptionForUnsupportedType(type);
			break;
			
		case _C_ARY_E:    // ']'
			description = DALDescriptionForUnsupportedType(type);
			break;
			
		case _C_UNION_B:  // '('
			description = DALDescriptionForUnsupportedType(type);
			break;
			
		case _C_UNION_E:  // ')'
			description = DALDescriptionForUnsupportedType(type);
			break;
			
		case _C_STRUCT_B: // '{'
		{
			NSString *typeString = [NSString stringWithUTF8String:type];
			if ([typeString hasPrefix:@"{CGPoint="])//ff}"])
			{
				CGPoint result = CGPointZero;
				object_getInstanceVariable(instance, name, (void *)&result);
				description = NSStringFromCGPoint(result);
			}
			else if ([typeString hasPrefix:@"{CGSize="])//ff}"])
			{
				CGSize result = CGSizeZero;
				object_getInstanceVariable(instance, name, (void *)&result);
				description = NSStringFromCGSize(result);
			}
			else if ([typeString hasPrefix:@"{CGRect="])//{CGPoint=ff}{CGSize=ff}}"])
			{
				CGRect result = CGRectZero;
				object_getInstanceVariable(instance, name, (void *)&result);
				description = NSStringFromCGRect(result);
			}
			else if ([typeString hasPrefix:@"{UIEdgeInsets="])//ffff}"])
			{
				UIEdgeInsets result = UIEdgeInsetsZero;
				object_getInstanceVariable(instance, name, (void *)&result);
				description = NSStringFromUIEdgeInsets(result);
			}
			else if ([typeString hasPrefix:@"{CGAffineTransform="])//ffffff}"])
			{
				CGAffineTransform result = CGAffineTransformMake(0, 0, 0, 0, 0, 0);
				object_getInstanceVariable(instance, name, (void *)&result);
				description = NSStringFromCGAffineTransform(result);
			}
			else
			{
                // TODO: Implement this
				description = @"(Unsupported struct...)";
			}
		}
			break;
			
		case _C_STRUCT_E: // '}'
			description = DALDescriptionForUnsupportedType(type);
			break;
			
		case _C_VECTOR:   // '!'
			description = DALDescriptionForUnsupportedType(type);
			break;
			
		case _C_CONST:    // 'r'
		{
			const char *result;
			result = (const char *)object_getIvar(instance, anIvar);
			description = [NSString stringWithUTF8String:result];
		}
			break;
			
		default:
			description = [NSString stringWithFormat:@"Warning! Unexpected return type: %s", type];
			break;
	}
	
	return description;
}

BOOL DALShouldIgnoreMethod(Method aMethod)
{
	char returnType[1];
	method_getReturnType(aMethod, returnType, 1);
	
	if (returnType[0] == _C_VOID)
		return YES;
	
	SEL selector = method_getName(aMethod);
	if (DALShouldIgnoreSelector(selector))
		return YES;
	
	return NO;
}

BOOL DALShouldIgnoreSelector(SEL selector)
{
	BOOL shouldIgnoreSelector = NO;
	
	NSString *string = NSStringFromSelector(selector);
	if ([string hasPrefix:@"_mapkit"] ||
		[string hasPrefix:@"create"] ||
		[string hasPrefix:@"initWith"] ||
		[string hasPrefix:@"layout"] ||
		[string hasPrefix:@"new"] ||
		[string isEqualToString:@"ancestryDescription"] ||
		[string isEqualToString:@"ancestryWithProtocolsDescription"] ||
		[string isEqualToString:@"ivarsDescription"] ||
		[string isEqualToString:@"methodsDescription"] ||
		[string isEqualToString:@"propertiesDescription"] ||
		[string isEqualToString:@"ivarsRecursiveDescription"] ||
		[string isEqualToString:@"methodsRecursiveDescription"] ||
		[string isEqualToString:@"propertiesRecursiveDescription"] ||
		[string isEqualToString:@".cxx_destruct"] ||
		[string isEqualToString:@"___tryRetain_OA"] ||
		[string isEqualToString:@"__autorelease_OA"] ||
		[string isEqualToString:@"__dealloc_zombie"] ||
		[string isEqualToString:@"__release_OA"] ||
		[string isEqualToString:@"__retain_OA"] ||
		[string isEqualToString:@"_caretRect"] ||
		[string isEqualToString:@"_gkStandardBackdropView"] ||
		[string isEqualToString:@"_hackFor11408026_beginAppearanceTransition:animated:"] || // UIViewController
		[string isEqualToString:@"_hackFor11408026_endAppearanceTransition"] ||
		[string isEqualToString:@"_initializeSafeCategoryFromValidationManager"] ||
		[string isEqualToString:@"_installSafeCategoryValidationMethod"] ||
		[string isEqualToString:@"_synchronizeDrawingAcrossProcesses"] ||
		[string isEqualToString:@"_tryRetain"] ||
		[string isEqualToString:@"autorelease"] ||
		[string isEqualToString:@"copy"] ||
		[string isEqualToString:@"dealloc"] ||
		[string isEqualToString:@"finalize"] ||
		[string isEqualToString:@"init"] ||
		[string isEqualToString:@"initialize"] ||
		[string isEqualToString:@"release"] ||
		[string isEqualToString:@"retain"] ||
//		[string isEqualToString:@"XPCInterface"] ||
		[string hasSuffix:@"Copy"] ||
		[string hasSuffix:@"Release"] ||
		[string hasSuffix:@"Retain"])
	{
		shouldIgnoreSelector = YES;
	}
	
	return shouldIgnoreSelector;
}

void DALInvokeMethodForResult(id instance, Method aMethod, void *result)
{
	SEL selector = method_getName(aMethod);
	if (DALShouldIgnoreSelector(selector))
	{
		result = nil;
	}
	else
	{
		char *types = DALTypesForMethod(aMethod);
		
		NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:types];
		NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
		[invocation setTarget:instance];
		[invocation setSelector:selector];
		@try
		{
			[invocation invoke];
			[invocation getArgument:&result atIndex:0];
		}
		@catch (NSException *exception)
		{
			NSString *selectorString = NSStringFromSelector(selector);
			NSString *objectString = NSStringFromClass([instance class]);
			NSLog(@"Warning! Unable to invoke selector '%@' on class '%@'. Exception: %@", selectorString, objectString, exception);
		}
        
        free(types);
	}
}

char *DALTypesForMethod(Method aMethod)
{
    char *types;
    
	size_t bufferLength = 10240;
	unsigned numberOfArguments = method_getNumberOfArguments(aMethod);
	
	size_t lengthOfTypes = bufferLength * (numberOfArguments + 1);
	types = malloc(lengthOfTypes);
	
	char returnType[bufferLength];
	method_getReturnType(aMethod, returnType, bufferLength);
	
	strcat(types, returnType);
	
	for (unsigned int argumentIndex = 0; argumentIndex < numberOfArguments; argumentIndex++)
	{
		char argumentType[bufferLength];
		method_getArgumentType(aMethod, argumentIndex, argumentType, bufferLength);
		strcat(types, argumentType);
	}
	
	return types;
}

#pragma mark - Swizzled method logging
void DALRetainAutorelease(id instance)
{
//	SEL retainSelector = ({
//		SEL sel = NULL;
//		
//		NSString *string = @"retain";
//		SEL swizzledSel = NSSelectorFromString([DALSwizzledPrefix stringByAppendingString:string]);
//		if ([instance respondsToSelector:swizzledSel])
//		{
//			sel = swizzledSel;
//		}
//		else
//			sel = NSSelectorFromString(string);
//		
//		sel;
//	});
//	SEL autoreleaseSelector = ({
//		SEL sel = NULL;
//		
//		NSString *string = @"autorelease";
//		SEL swizzledSel = NSSelectorFromString([DALSwizzledPrefix stringByAppendingString:string]);
//		if ([instance respondsToSelector:swizzledSel])
//		{
//			sel = swizzledSel;
//		}
//		else
//			sel = NSSelectorFromString(string);
//		sel;
//	});
//	[[object performSelector:retainSelector] performSelector:autoreleaseSelector];
}

void DALSwizzleInstanceMethodsForClass(Class aClass)
{
	unsigned int numberOfMethods = 0;
	Method *methods = class_copyMethodList(aClass, &numberOfMethods);
	for (unsigned int methodIndex = 0; methodIndex < numberOfMethods; methodIndex++)
	{
		Method aMethod = methods[methodIndex];
		
		SEL originalName = method_getName(aMethod);
		SEL name = NSSelectorFromString([DALSwizzledPrefix stringByAppendingString:NSStringFromSelector(originalName)]);
		IMP imp = imp_implementationWithBlock(DALImplementationBlockForMethod(aMethod, name, originalName));
		
		char *types = DALTypesForMethod(aMethod);
		
		if (class_addMethod(aClass, name, imp, types))
		{
			Method m1 = aMethod;
			Method m2 = class_getInstanceMethod(aClass, name);
			method_exchangeImplementations(m1, m2);
		}
		else
		{
			NSLog(@"*** Error! Unable to add method: %@", NSStringFromSelector(name));
		}
		
		free(types);
	}
}

id DALImplementationBlockForMethod(Method aMethod, SEL swizzledSelector, SEL originalSelector)
{
	id block = nil;
	
	unsigned numberOfArguments = method_getNumberOfArguments(aMethod) - 2;
	
	char returnType[1];
	method_getReturnType(aMethod, returnType, 1);
	switch (returnType[0])
	{
		case _C_VOID:
			block = DALBlockWithVoidReturnAndNumberOfArguments(numberOfArguments, swizzledSelector, originalSelector);
			break;
			
		case _C_STRUCT_B:
			block = DALBlockWithStructReturnAndNumberOfArguments(numberOfArguments, swizzledSelector, originalSelector);
			break;
			
		default:
			block = DALBlockWithIdReturnAndNumberOfArguments(numberOfArguments, swizzledSelector, originalSelector);
			break;
	}
	
	return block;
}

id DALBlockWithVoidReturnAndNumberOfArguments(unsigned numberOfArguments, SEL swizzledSelector, SEL originalSelector)
{
	id block = nil;
	
	switch (numberOfArguments)
	{
		case 0:
			block = [^void(id __strong blockSelf) {
				
				if ([NSStringFromSelector(originalSelector) isEqualToString:@"retain"])
				{
					static int count = 0;
					if (count > 5)
					{
						NSLog(@"%@", [NSThread callStackSymbols]);
					}
					count++;
					
				}
				
				NSLog(@"<%@: %p> SEL: %@", NSStringFromClass([blockSelf class]), blockSelf, NSStringFromSelector(originalSelector));
				DALRetainAutorelease(blockSelf);
				objc_msgSend(blockSelf, swizzledSelector, NULL);
			} copy];
			break;
			
		case 1:
			block = [^void(id __strong blockSelf, void *arg) {
				
				NSLog(@"<%@: %p> SEL: %@", NSStringFromClass([blockSelf class]), blockSelf, NSStringFromSelector(originalSelector));
				DALRetainAutorelease(blockSelf);
				objc_msgSend(blockSelf, swizzledSelector, arg);
			} copy];
			break;
			
		case 2:
			block = [^void(id __strong blockSelf, void *arg1, void *arg2) {
				
				NSLog(@"<%@: %p> SEL: %@", NSStringFromClass([blockSelf class]), blockSelf, NSStringFromSelector(originalSelector));
				DALRetainAutorelease(blockSelf);
				objc_msgSend(blockSelf, swizzledSelector, arg1, arg2);
			} copy];
			break;
			
		case 3:
			block = [^void(id __strong blockSelf, void *arg1, void *arg2, void *arg3) {
				
				NSLog(@"<%@: %p> SEL: %@", NSStringFromClass([blockSelf class]), blockSelf, NSStringFromSelector(originalSelector));
				DALRetainAutorelease(blockSelf);
				objc_msgSend(blockSelf, swizzledSelector, arg1, arg2, arg3);
			} copy];
			break;
			
		case 4:
			block = [^void(id __strong blockSelf, void *arg1, void *arg2, void *arg3, void *arg4) {
				
				NSLog(@"<%@: %p> SEL: %@", NSStringFromClass([blockSelf class]), blockSelf, NSStringFromSelector(originalSelector));
				DALRetainAutorelease(blockSelf);
				objc_msgSend(blockSelf, swizzledSelector, arg1, arg2, arg3, arg4);
			} copy];
			break;
			
		case 5:
			block = [^void(id __strong blockSelf, void *arg1, void *arg2, void *arg3, void *arg4, void *arg5) {
				
				NSLog(@"<%@: %p> SEL: %@", NSStringFromClass([blockSelf class]), blockSelf, NSStringFromSelector(originalSelector));
				DALRetainAutorelease(blockSelf);
				objc_msgSend(blockSelf, swizzledSelector, arg1, arg2, arg3, arg4, arg5);
			} copy];
			break;
			
		default:
			NSLog(@"*** Error! Method requires '%u' parameters", numberOfArguments);
			break;
	}
	
	return block;
}

id DALBlockWithStructReturnAndNumberOfArguments(unsigned numberOfArguments, SEL swizzledSelector, SEL originalSelector)
{
	id block = nil;
	
	switch (numberOfArguments)
	{
		case 0:
			block = [^void *(id __strong blockSelf) {
				
				if ([NSStringFromSelector(originalSelector) isEqualToString:@"retain"])
				{
					static int count = 0;
					if (count > 5)
					{
						NSLog(@"%@", [NSThread callStackSymbols]);
					}
					count++;
					
				}
				
				NSLog(@"<%@: %p> SEL: %@", NSStringFromClass([blockSelf class]), blockSelf, NSStringFromSelector(originalSelector));
				DALRetainAutorelease(blockSelf);
				void *value;
				value = ((void *(*)(id, SEL, void *))objc_msgSend_stret)(blockSelf, swizzledSelector, NULL);
				return value;
			} copy];
			break;
			
		case 1:
			block = [^void *(id __strong blockSelf, void *arg) {
				
				NSLog(@"<%@: %p> SEL: %@", NSStringFromClass([blockSelf class]), blockSelf, NSStringFromSelector(originalSelector));
				DALRetainAutorelease(blockSelf);
				void *value;
				value = ((void *(*)(id, SEL, void *))objc_msgSend_stret)(blockSelf, swizzledSelector, arg);
				return value;
			} copy];
			break;
			
		case 2:
			block = [^void *(id __strong blockSelf, void *arg1, void *arg2) {
				
				NSLog(@"<%@: %p> SEL: %@", NSStringFromClass([blockSelf class]), blockSelf, NSStringFromSelector(originalSelector));
				DALRetainAutorelease(blockSelf);
				void *value;
				value = ((void *(*)(id, SEL, void *, void *))objc_msgSend_stret)(blockSelf, swizzledSelector, arg1, arg2);
				return value;
			} copy];
			break;
			
		case 3:
			block = [^void *(id __strong blockSelf, void *arg1, void *arg2, void *arg3) {
				
				NSLog(@"<%@: %p> SEL: %@", NSStringFromClass([blockSelf class]), blockSelf, NSStringFromSelector(originalSelector));
				DALRetainAutorelease(blockSelf);
				void *value;
				value = ((void *(*)(id, SEL, void *, void *, void *))objc_msgSend_stret)(blockSelf, swizzledSelector, arg1, arg2, arg3);
				return value;
			} copy];
			break;
			
		case 4:
			block = [^void *(id __strong blockSelf, void *arg1, void *arg2, void *arg3, void *arg4) {
				
				NSLog(@"<%@: %p> SEL: %@", NSStringFromClass([blockSelf class]), blockSelf, NSStringFromSelector(originalSelector));
				DALRetainAutorelease(blockSelf);
				void *value;
				value = ((void *(*)(id, SEL, void *, void *, void *, void *))objc_msgSend_stret)(blockSelf, swizzledSelector, arg1, arg2, arg3, arg4);
				return value;
			} copy];
			break;
			
		case 5:
			block = [^void *(id __strong blockSelf, void *arg1, void *arg2, void *arg3, void *arg4, void *arg5) {
				
				NSLog(@"<%@: %p> SEL: %@", NSStringFromClass([blockSelf class]), blockSelf, NSStringFromSelector(originalSelector));
				DALRetainAutorelease(blockSelf);
				void *value;
				value = ((void *(*)(id, SEL, void *, void *, void *, void *, void *))objc_msgSend_stret)(blockSelf, swizzledSelector, arg1, arg2, arg3, arg4, arg5);
				return value;
			} copy];
			break;
			
		default:
			NSLog(@"*** Error! Method requires '%u' parameters", numberOfArguments);
			break;
	}
	
	return block;
}

id DALBlockWithIdReturnAndNumberOfArguments(unsigned numberOfArguments, SEL swizzledSelector, SEL originalSelector)
{
	id block = nil;
	
	switch (numberOfArguments)
	{
		case 0:
			block = [^id(id __strong blockSelf) {
				
				if ([NSStringFromSelector(originalSelector) isEqualToString:@"retain"])
				{
					static int count = 0;
					if (count > 5)
					{
						NSLog(@"%@", [NSThread callStackSymbols]);
					}
					count++;
					
				}
				
				NSLog(@"<%@: %p> SEL: %@", NSStringFromClass([blockSelf class]), blockSelf, NSStringFromSelector(originalSelector));
				DALRetainAutorelease(blockSelf);
				id value = objc_msgSend(blockSelf, swizzledSelector);
				return value;
			} copy];
			break;
			
		case 1:
			block = [^id(id __strong blockSelf, void *arg) {
				
				NSLog(@"<%@: %p> SEL: %@", NSStringFromClass([blockSelf class]), blockSelf, NSStringFromSelector(originalSelector));
				DALRetainAutorelease(blockSelf);
				id value = objc_msgSend(blockSelf, swizzledSelector, arg);
				return value;
			} copy];
			break;
			
		case 2:
			block = [^id(id __strong blockSelf, void *arg1, void *arg2) {
				
				NSLog(@"<%@: %p> SEL: %@", NSStringFromClass([blockSelf class]), blockSelf, NSStringFromSelector(originalSelector));
				DALRetainAutorelease(blockSelf);
				id value = objc_msgSend(blockSelf, swizzledSelector, arg1, arg2);
				return value;
			} copy];
			break;
			
		case 3:
			block = [^id(id __strong blockSelf, void *arg1, void *arg2, void *arg3) {
				
				NSLog(@"<%@: %p> SEL: %@", NSStringFromClass([blockSelf class]), blockSelf, NSStringFromSelector(originalSelector));
				DALRetainAutorelease(blockSelf);
				id value = objc_msgSend(blockSelf, swizzledSelector, arg1, arg2, arg3);
				return value;
			} copy];
			break;
			
		case 4:
			block = [^id(id __strong blockSelf, void *arg1, void *arg2, void *arg3, void *arg4) {
				
				NSLog(@"<%@: %p> SEL: %@", NSStringFromClass([blockSelf class]), blockSelf, NSStringFromSelector(originalSelector));
				DALRetainAutorelease(blockSelf);
				id value = objc_msgSend(blockSelf, swizzledSelector, arg1, arg2, arg3, arg4);
				return value;
			} copy];
			break;
			
		case 5:
			block = [^id(id __strong blockSelf, void *arg1, void *arg2, void *arg3, void *arg4, void *arg5) {
				
				NSLog(@"<%@: %p> SEL: %@", NSStringFromClass([blockSelf class]), blockSelf, NSStringFromSelector(originalSelector));
				DALRetainAutorelease(blockSelf);
				id value = objc_msgSend(blockSelf, swizzledSelector, arg1, arg2, arg3, arg4, arg5);
				return value;
			} copy];
			break;
			
		default:
			NSLog(@"*** Error! Method requires '%u' parameters", numberOfArguments);
			break;
	}
	
	return block;
}

#endif
