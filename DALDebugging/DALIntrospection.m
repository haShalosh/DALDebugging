//
//  DALIntrospection.m
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
#import <objc/runtime.h>
#import <objc/message.h>
#import "ApplePrivate.h"

#define DAL_C_INOUT		'N'
#define DAL_C_OUT		'o'
#define DAL_C_ONEWAY	'V'

OBJC_EXPORT id DAL___methodDescription(Method aMethod, BOOL isClassMethod);
OBJC_EXPORT id DAL___typeEncodingDescription(const char *typeEncoding);
OBJC_EXPORT id DAL___propertyAttributeDescription(objc_property_attribute_t attribute);

#pragma mark -
#pragma mark - Class

OBJC_EXPORT id DALClassIvarDescription(Class aClass)
{
	NSMutableString *description = [NSMutableString string];
	
	[description appendFormat:@"in %@", NSStringFromClass(aClass)];
	
	// Protocols
	unsigned int numberOfProtocols = 0;
	Protocol * __unsafe_unretained *protocolList = class_copyProtocolList(aClass, &numberOfProtocols);
	for (unsigned int i = 0; i < numberOfProtocols; i++)
	{
		if (i == 0)
		{
			[description appendString:@" <"];
		}
		else
		{
			[description appendString:@", "];
		}
		
		Protocol *aProtocol = protocolList[i];
		NSString *name = @(protocol_getName(aProtocol));
		[description appendString:name];
	}
	
	if (protocolList)
	{
		free(protocolList);
	}
	
	if (numberOfProtocols != 0)
	{
		[description appendString:@">"];
	}
	
	[description appendString:@":\n"];
	
	// Ivars
	unsigned int numberOfIvars = 0;
	Ivar *ivarList = class_copyIvarList(aClass, &numberOfIvars);
	for (unsigned int i = 0; i < numberOfIvars; i++)
	{
		Ivar anIvar = ivarList[i];
		
		const char *name = ivar_getName(anIvar);
		const char *typeEncoding = ivar_getTypeEncoding(anIvar);
		NSString *typeEncodingDescription = DAL___typeEncodingDescription(typeEncoding);
		[description appendFormat:@"\t%s (%@)\n", name, typeEncodingDescription];
	}
	
	if (ivarList)
	{
		free(ivarList);
	}
	
	return description;
}

OBJC_EXPORT id DALClassMethodDescription(Class aClass)
{
	NSMutableString *description = [NSMutableString string];
	
	[description appendFormat:@"%@:\n", NSStringFromClass(aClass)];
	
	Class introspectedClass = aClass;
	while (introspectedClass)
	{
		NSString *classDescription = DAL__methodDescriptionForClass(nil, introspectedClass);
		[description appendString:classDescription];
		
		introspectedClass = [introspectedClass superclass];
	}
	
	return description;
}

OBJC_EXPORT id DALClassShortMethodDescription(Class aClass)
{
	NSMutableString *description = [NSMutableString string];
	
	[description appendFormat:@"%@:\n", NSStringFromClass(aClass)];
	
	Class introspectedClass = aClass;
	while (introspectedClass)
	{
		NSString *classDescription = DAL__methodDescriptionForClass(nil, introspectedClass);
		[description appendString:classDescription];
		
		introspectedClass = [introspectedClass superclass];
		
		// Ignore all superclasses that have the prefix NS
		NSString *className = NSStringFromClass(introspectedClass);
		if (className.length >= 4)
		{
			if ([className characterAtIndex:0] == 'N' &&
				[className characterAtIndex:1] == 'S' &&
				[[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[className characterAtIndex:2]] &&
				[[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:[className characterAtIndex:3]])
			{
				[description appendFormat:@"(%@ ...)\n", NSStringFromClass(introspectedClass)];
				
				introspectedClass = nil;
			}
		}
	}
	
	return description;
}


#pragma mark - Instance

id DAL_ivarDescription(id instance)
{
	NSMutableString *description = [NSMutableString string];
	
	[description appendFormat:@"%@:\n", [instance description]];
	
	Class aClass = [instance class];
	while (aClass)
	{
		NSString *classDescription = DAL__ivarDescriptionForClass(instance, aClass);
		[description appendString:classDescription];
		
		aClass = [aClass superclass];
	}
	
	return description;
}

id DAL_methodDescription(id instance)
{
	NSMutableString *description = [NSMutableString string];
	
	[description appendFormat:@"%@:\n", [instance description]];
	
	Class aClass = [instance class];
	while (aClass)
	{
		NSString *classDescription = DAL__methodDescriptionForClass(instance, aClass);
		[description appendString:classDescription];
		
		aClass = [aClass superclass];
	}
	
	return description;
}

id DAL_shortMethodDescription(id instance)
{
	NSMutableString *description = [NSMutableString string];
	
	[description appendFormat:@"%@:\n", [instance description]];
	
	Class aClass = [instance class];
	while (aClass)
	{
		NSString *classDescription = DAL__methodDescriptionForClass(instance, aClass);
		[description appendString:classDescription];
		
		aClass = [aClass superclass];
		
		// Ignore all superclasses that have the prefix NS
		NSString *className = NSStringFromClass(aClass);
		if (className.length >= 4)
		{
			if ([className characterAtIndex:0] == 'N' &&
				[className characterAtIndex:1] == 'S' &&
				[[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[className characterAtIndex:2]] &&
				[[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:[className characterAtIndex:3]])
			{
				[description appendFormat:@"(%@ ...)\n", NSStringFromClass(aClass)];
				
				aClass = nil;
			}
		}
	}
	
	return description;
}

#pragma mark -

id DAL__ivarDescriptionForClass(id instance, Class aClass)
{
	NSMutableString *description = [NSMutableString string];
	
	[description appendFormat:@"in %@", NSStringFromClass(aClass)];
	
	// Protocols
	unsigned int numberOfProtocols = 0;
	Protocol * __unsafe_unretained *protocolList = class_copyProtocolList(aClass, &numberOfProtocols);
	for (unsigned int i = 0; i < numberOfProtocols; i++)
	{
		if (i == 0)
		{
			[description appendString:@" <"];
		}
		else
		{
			[description appendString:@", "];
		}
		
		Protocol *aProtocol = protocolList[i];
		NSString *name = @(protocol_getName(aProtocol));
		[description appendString:name];
	}
	
	if (protocolList)
	{
		free(protocolList);
	}
	
	if (numberOfProtocols != 0)
	{
		[description appendString:@">"];
	}
	
	[description appendString:@":\n"];
	
	// Ivars
	unsigned int numberOfIvars = 0;
	Ivar *ivarList = class_copyIvarList(aClass, &numberOfIvars);
	for (unsigned int i = 0; i < numberOfIvars; i++)
	{
		Ivar anIvar = ivarList[i];
		
		const char *name = ivar_getName(anIvar);
		const char *typeEncoding = ivar_getTypeEncoding(anIvar);
		NSString *typeEncodingDescription = DAL___typeEncodingDescription(typeEncoding);
		NSString *key = @(name);
		[description appendFormat:@"\t%s (%@)", name, typeEncodingDescription];
		
		// TODO: Determine what Apple's -_ivarDescription method grabs.
		BOOL didGetValueForKey = YES;
		
		id value = nil;
		
		if (strcmp(name, "isa") == 0)
		{
			value = NSStringFromClass(object_getClass(instance));
			[description appendFormat:@": %@", value];
		}
		else
		{
			@try
			{
				value = [instance valueForKey:key];
			}
			@catch (NSException *exception)
			{
				didGetValueForKey = NO;
			}
			
			if (didGetValueForKey)
			{
				[description appendString:@": "];
				
				if (value == nil)
				{
					[description appendString:@"nil"];
				}
				else
				{
					if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSValue class]])
					{
						[description appendFormat:@"%@", value];
					}
					else if ([value isKindOfClass:[NSString class]])
					{
						[description appendFormat:@"@\"%@\"", value];
					}
					else
					{
						[description appendFormat:@"<%@: %p>", NSStringFromClass([value class]), value];
					}
				}
			}
		}
		
		[description appendString:@"\n"];
	}
	
	if (ivarList)
	{
		free(ivarList);
	}
	
	return description;
}

id DAL__methodDescriptionForClass(id instance, Class aClass)
{
	// TODO: Determine why Apple's -__methodDescription introspects the following: - (id) CA_interpolateValues:(id)arg1 :(id)arg2 :(id)arg3 interpolator:(const ValueInterpolator*)arg4; (0x1876706)

	NSMutableString *description = [NSMutableString string];
	
	[description appendFormat:@"in %@", NSStringFromClass(aClass)];
	
	// Protocols
	unsigned int numberOfProtocols = 0;
	Protocol * __unsafe_unretained *protocolList = class_copyProtocolList(aClass, &numberOfProtocols);
	for (unsigned int i = 0; i < numberOfProtocols; i++)
	{
		if (i == 0)
		{
			[description appendString:@" <"];
		}
		else
		{
			[description appendString:@", "];
		}
		
		Protocol *aProtocol = protocolList[i];
		NSString *name = @(protocol_getName(aProtocol));
		[description appendString:name];
	}
	
	if (protocolList)
	{
		free(protocolList);
	}
	
	if (numberOfProtocols != 0)
	{
		[description appendString:@">"];
	}
	
	[description appendString:@":\n"];
	
	// Class Methods
	unsigned int numberOfClassMethods = 0;
	Class metaClass = object_getClass(aClass);
	Method *classMethodList = class_copyMethodList(metaClass, &numberOfClassMethods);
	
	if (numberOfClassMethods)
	{
		[description appendString:@"\tClass Methods:\n"];
		
		for (unsigned int i = 0; i < numberOfClassMethods; i++)
		{
			Method aMethod = classMethodList[i];
			id methodDescription = DAL___methodDescription(aMethod, YES);
			[description appendString:@"\t\t"];
			[description appendString:methodDescription];
		}
	}
	
	if (classMethodList)
	{
		free(classMethodList);
	}
	
	// Properties
	unsigned int numberOfProperties = 0;
	objc_property_t *propertyList = class_copyPropertyList(aClass, &numberOfProperties);
	
	if (numberOfProperties)
	{
		[description appendString:@"\tProperties:\n"];
		
		for (unsigned int i = 0; i < numberOfProperties; i++)
		{
			[description appendString:@"\t\t@property "];
			
			objc_property_t aProperty = propertyList[i];
			
			NSString *type = nil;
			NSString *ivarName = nil;
			BOOL isDynamic = NO;
			
			// Attributes
			unsigned int numberOfAttributes = 0;
			objc_property_attribute_t *attributeList = property_copyAttributeList(aProperty, &numberOfAttributes);
			if (numberOfAttributes)
			{
				[description appendString:@"("];
				
				for (unsigned int i = 0; i < numberOfAttributes; i++)
				{
					objc_property_attribute_t attribute = attributeList[i];
					
					if (strcmp(attribute.name, "T") == 0) // Type
					{
						type = DAL___typeEncodingDescription(attribute.value);
					}
					else if (strcmp(attribute.name, "V") == 0) // Ivar
					{
						ivarName = @(attribute.value);
					}
					else if (strcmp(attribute.name, "D") == 0)
					{
						isDynamic = YES;
					}
					else
					{
						if ([description characterAtIndex:description.length - 1] != '(')
						{
							[description appendString:@", "];
						}
						
						// TODO: Determine why Apple is ignoring the 'dynamic' property attribute.
						NSString *attributeDescription = DAL___propertyAttributeDescription(attribute);
						[description appendString:attributeDescription];
					}
				}
				
				[description appendString:@") "];
			}
			
			if (attributeList)
			{
				free(attributeList);
			}
			
			// Type
			[description appendString:type];
			[description appendString:@" "];
			
			// Name
			NSString *name = @(property_getName(aProperty));
			[description appendString:name];
			
			[description appendString:@";"];
			
			// Synthesis
			if (ivarName)
			{
				[description appendFormat:@"  (@synthesize %@ = %@;)", name, ivarName];
			}
			else if (isDynamic)
			{
				[description appendFormat:@"  (@dynamic %@;)", name];
			}
			
			[description appendString:@"\n"];
		}
	}
	
	if (propertyList)
	{
		free(propertyList);
	}
	
	// Instance Methods
	unsigned int numberOfInstanceMethods = 0;
	Method *instanceMethodList = class_copyMethodList(aClass, &numberOfInstanceMethods);
	
	if (numberOfInstanceMethods)
	{
		[description appendString:@"\tInstance Methods:\n"];
		
		for (unsigned int i = 0; i < numberOfInstanceMethods; i++)
		{
			Method aMethod = instanceMethodList[i];
			id methodDescription = DAL___methodDescription(aMethod, NO);
			[description appendString:@"\t\t"];
			[description appendString:methodDescription];
		}
	}
	
	if (instanceMethodList)
	{
		free(instanceMethodList);
	}
	
	return description;
}

#pragma mark -

id DAL___methodDescription(Method aMethod, BOOL isClassMethod)
{
	NSMutableString *description = [NSMutableString string];
	
	char *returnType = method_copyReturnType(aMethod);
	NSString *returnTypeDescription = DAL___typeEncodingDescription(returnType);
	
	[description appendFormat:@"%@ (%@) ", isClassMethod ? @"+" : @"-", returnTypeDescription];
	
	if (returnType)
	{
		free(returnType);
	}
	
	NSString *name = NSStringFromSelector(method_getName(aMethod));
	
	unsigned int numberOfArguments = method_getNumberOfArguments(aMethod);
	if (numberOfArguments == 2)
	{
		[description appendFormat:@"%@", name];
	}
	else
	{
		NSArray *nameComponents = [name componentsSeparatedByString:@":"];
		
		for (unsigned int i = 2; i < numberOfArguments; i++)
		{
			if (i > 2)
			{
				[description appendString:@" "];
			}
			
			NSString *nameComponent = nameComponents[i - 2];
			[description appendFormat:@"%@:", nameComponent];
			
			char *argumentType = method_copyArgumentType(aMethod, i);
			NSString *argumentTypeDescription = DAL___typeEncodingDescription(argumentType);
			
			[description appendFormat:@"(%@)arg%d", argumentTypeDescription, i - 1];
			
			if (argumentType)
			{
				free(argumentType);
			}
		}
	}
	
	IMP anImplementation = method_getImplementation(aMethod);
	[description appendFormat:@"; (%p)\n", anImplementation];
	
	return description;
}

id DAL___typeEncodingDescription(const char *typeEncoding)
{
	NSString *description;
	
	char firstChar = typeEncoding[0];
	switch (firstChar)
	{
		case _C_ID:		// '@'
		{
			if (strlen(typeEncoding) == 1)
			{
				description = @"id";
			}
			else
			{
				NSString *string = @(typeEncoding);
				
				if ([string characterAtIndex:1] == '"')
				{
					NSRange firstQuotationRange = [string rangeOfString:@"\"" options:0];
					NSRange lastQuotationRange = [string rangeOfString:@"\"" options:NSBackwardsSearch];
					if (firstQuotationRange.location != lastQuotationRange.location && firstQuotationRange.location != NSNotFound && lastQuotationRange.location != NSNotFound)
					{
						NSUInteger location = firstQuotationRange.location + firstQuotationRange.length;
						NSRange range = NSMakeRange(location, lastQuotationRange.location - location);
						string = [string substringWithRange:range];
						string = [string stringByAppendingString:@"*"];
						
						description = string;
					}
#if DEMO
					else
					{
						NSLog(@"*** Error! Unable to parse: %s", typeEncoding);
					}
#endif
				}
				else if ([string characterAtIndex:1] == _C_UNDEF)
				{
					description = @"^block";
				}
#if DEMO
				else
				{
					NSLog(@"*** Error! Unable to parse: %s", typeEncoding);
				}
#endif
			}
		}
			break;
			
		case _C_CLASS:		// '#'
			description = @"Class";
			break;
			
		case _C_SEL:		// ':'
			description = @"SEL";
			break;
			
		case _C_UCHR:		// 'C'
			description = @"unsigned char";
			break;
			
		case _C_SHT:		// 's'
			description = @"short";
			break;
			
		case _C_USHT:		// 'S'
			description	= @"unsigned short";
			break;
			
		case _C_INT:		// 'i'
			description = @"int";
			break;
			
		case _C_UINT:		// 'I'
			description = @"unsigned int";
			break;
			
		case _C_LNG:		// 'l'
			description = @"long";
			break;
			
		case _C_ULNG:		// 'L'
			description = @"unsigned long";
			break;
			
		case _C_LNG_LNG:	// 'q'
			description = @"long long";
			break;
			
		case _C_ULNG_LNG:	// 'Q'
			description = @"unsigned long long";
			break;
			
		case _C_FLT:		// 'f'
			description = @"float";
			break;
			
		case _C_DBL:		// 'd'
			description = @"double";
			break;
			
		case _C_BFLD:		// 'b'
			description = @"BFLD";
			break;
			
		case _C_CHR:		// 'c' // A BOOL is encoded an a char. Apple's -_methodDescription behaves this way.
		case _C_BOOL:		// 'B'
			description = @"BOOL";
			break;
			
		case _C_VOID:		// 'v'
			description = @"void";
			break;
			
		case DAL_C_ONEWAY:	// 'V'
			if (strlen(typeEncoding) >= 2 && typeEncoding[1] == _C_VOID)
			{
				description = @"oneway void";
			}
			break;
			
		case _C_UNDEF:		// '?'
			description = [NSString stringWithFormat:@"%c", _C_UNDEF];
			break;
			
		case _C_PTR:		// '^'
		{
			NSString *subDescription = DAL___typeEncodingDescription(typeEncoding + 1);
			description = [subDescription stringByAppendingString:@"*"];
			// TODO: Determine why Apple doesn't include '*' when the subDescription is 'id'.
		}
			break;
			
		case _C_CHARPTR:	// '*'
			description = @"char*";
			break;
			
		case _C_STRUCT_B:	// '{'
		{
			if (strlen(typeEncoding) > 1 && typeEncoding[1] == _C_UNDEF)
			{
				description = [NSString stringWithFormat:@"%c", _C_UNDEF];
			}
			else
			{
				NSString *string = @(typeEncoding);
				
				NSRange equalsSignRange = [string rangeOfString:@"="];
				if (equalsSignRange.location != NSNotFound)
				{
					NSUInteger offset = 1;
					NSRange range = NSMakeRange(offset, equalsSignRange.location - offset);
					description = [string substringWithRange:range];
				}
#if DEMO
				else
				{
					NSLog(@"*** Error! Unable to parse: %s", typeEncoding);
				}
#endif
			}
		}
			break;
			
		case _C_CONST:		// 'r'
		{
			NSString *subDescription = DAL___typeEncodingDescription(typeEncoding + 1);
			description = [NSString stringWithFormat:@"const %@", subDescription];
		}
			break;
			
		case DAL_C_INOUT:	// 'N'
		case DAL_C_OUT:		// 'o'
		{
			NSString *prefix = nil;
			
			switch (firstChar)
			{
				case DAL_C_INOUT:
					prefix = @"inout";
					break;
					
				case DAL_C_OUT:
					prefix = @"out";
					break;
					
				default:
#if DEMO
					NSLog(@"Warning! Uncaught type: %c", firstChar);
#endif
					break;
			}
			
			BOOL isID = NO;
			BOOL isPointer = NO;
			
			size_t length = strlen(typeEncoding);
			for (size_t i = 1; i < length; i++)
			{
				char aChar = typeEncoding[i];
				switch (aChar)
				{
					case _C_PTR:	// '^'
						isPointer = YES;
						break;
						
					case _C_ID:		// '@'
						isID = YES;
						break;
						
					default:
						break;
				}
			}
			
			NSMutableString *mutableString = [NSMutableString stringWithString:prefix];
			if (isID || isPointer)
			{
				[mutableString appendString:@" "];
			}
			
			if (isID)
			{
				[mutableString appendString:@"id"];
			}
			
			if (isPointer)
			{
				[mutableString appendString:@"*"];
			}
			
			description = mutableString;
		}
			break;
			
		case _C_ATOM:		// '%'
		case _C_ARY_B:		// '['
		case _C_ARY_E:		// ']'
		case _C_UNION_B:	// '('
		case _C_UNION_E:	// ')'
		case _C_STRUCT_E:	// '}'
		case _C_VECTOR:		// '!'
		case 'D': // +[PFUbiquityBaseline requiredFractionOfDiskSpaceUsedForLogs];
		case 'R': // -[_UIViewServiceSession __requestConnectionToDeputyOfClass:fromHostObject:replyHandler:];
		default:
#if DEMO
			NSLog(@"*** unsupported type: %s", typeEncoding);
#endif
			break;
	}
	
	if (description == nil)
	{
		description = @"unknown type";
	}
	
	return description;
}

id DAL___propertyAttributeDescription(objc_property_attribute_t attribute)
{
	NSString *description = nil;
	
	const char *name = attribute.name;
	const char *value = attribute.value;
	
	switch (name[0])
	{
		case 'C':
			description = @"copy";
			break;
			
		case 'D':
			description = @"dynamic";
			break;
			
		case 'G':
			description = [NSString stringWithFormat:@"getter=%s", value];
			break;
			
		case 'N':
			description = @"nonatomic";
			break;
			
		case 'P':
			description = @"{garbage collection}";
			break;
			
		case 'R':
			description = @"readonly";
			break;
			
		case 'S':
			description = [NSString stringWithFormat:@"setter=%s", value];
			break;
			
		case 'T':
		case 't':
			description = [NSString stringWithFormat:@"type=%s", value];
			break;
			
		case 'V':
			description = [NSString stringWithFormat:@"Ivar=%s", value];
			break;
			
		case 'W':
			description = @"weak";
			break;
			
		case '&':
			description = @"retain";
			break;
			
		default:
			description = [NSString stringWithFormat:@"unknown type"];
			break;
	}
	
	return description;
}

#endif
