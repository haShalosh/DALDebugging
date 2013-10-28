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
#import "DALIntrospection+Helper.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "ApplePrivate.h"

NSString * const DALSwizzledPrefix = @"DALSwizzled_";

#pragma mark -
#pragma mark Class Introspection
NSString *DALClassAncestryWithProtocolsDescription(Class aClass, BOOL withProtocols)
{
	NSMutableString *description = [NSMutableString stringWithString:NSStringFromClass(aClass)];
	
	if (withProtocols)
		[description appendString:DALDescriptionOfProtocolsForClass(aClass)];
	
	Class superclass = [aClass superclass];
	while (superclass)
	{
		[description appendFormat:@" : %@", NSStringFromClass(superclass)];
		
		if (withProtocols)
			[description appendString:DALDescriptionOfProtocolsForClass(superclass)];
		
		superclass = [superclass superclass];
	}
	
	return description;
}

NSString *DALClassIvarsDescription(Class aClass)
{
	NSMutableArray *array = [NSMutableArray array];
	
	unsigned int numberOfIvars = 0;
	Ivar *ivars = class_copyIvarList(aClass, &numberOfIvars);
	for (unsigned int i = 0; i < numberOfIvars; i++)
	{
		Ivar anIvar = ivars[i];
		const char *returnTypeChar = ivar_getTypeEncoding(anIvar);
		NSString *returnTypeDescription = DALDescriptionOfReturnOrParameterType(returnTypeChar);
		
		const char *nameChar = ivar_getName(anIvar);
		NSString *name = [NSString stringWithUTF8String:nameChar];
		
		NSString *ivarDescription = [NSString stringWithFormat:@"%@ %@", returnTypeDescription, name];
		
		[array addObject:ivarDescription];
	}
	
	NSMutableString *description = [NSMutableString string];
	for (NSString *string in array)
	{
		[description appendFormat:@"%@\n", string];
	}
	
	if (array.count)
		[description deleteCharactersInRange:NSMakeRange(description.length - 1, 1)];
	
	return description;
}

NSString *DALClassMethodsDescription(Class aClass)
{
	NSArray *(^arrayOfMethodsForClass)(Class aClass, BOOL useMetaClass) = ^NSArray *(Class aClass, BOOL useMetaClass) {
		
		NSMutableArray *array = [NSMutableArray array];
		
		if (useMetaClass)
			aClass = objc_getMetaClass(class_getName(aClass));
		
		unsigned int numberOfMethods;
		Method *classMethods = class_copyMethodList(aClass, &numberOfMethods);
		
		for (unsigned int methodIndex = 0; methodIndex < numberOfMethods; methodIndex++)
		{
			NSMutableString *methodString = [NSMutableString string];
			
			Method aMethod = classMethods[methodIndex];
			SEL selector = method_getName(aMethod);
			if ([NSStringFromSelector(selector) hasPrefix:DALSwizzledPrefix])
			{
				NSString *string = NSStringFromSelector(selector);
				string = [string stringByReplacingOccurrencesOfString:DALSwizzledPrefix withString:@""];
				SEL originalSelector = NSSelectorFromString(string);
				if (useMetaClass)
					aMethod = class_getClassMethod(aClass, originalSelector);
				else
					aMethod = class_getInstanceMethod(aClass, originalSelector);
			}
			
			NSString *name = NSStringFromSelector(selector);
			
			// method type (class or instance)
			if (useMetaClass)
				[methodString appendString:@"+"];
			else
				[methodString appendString:@"-"];
			
			// return type
			[methodString appendString:@" ("];
			
			unsigned int charLength = 1024 * 4;
			char returnTypeChar[charLength];
			method_getReturnType(aMethod, returnTypeChar, charLength);
			NSString *returnTypeDescription = DALDescriptionOfReturnOrParameterType(returnTypeChar);
			if ([returnTypeDescription isEqualToString:@"id"] &&
				( (useMetaClass && [name hasPrefix:@"new"]) || (!useMetaClass && [name hasPrefix:@"init"]) )
				)
			{
				returnTypeDescription = @"instancetype";
				if (useMetaClass)
					NSLog(@"meta class new method");
			}
			
			[methodString appendString:returnTypeDescription];
			
			[methodString appendString:@")"];
			
			unsigned numberOfArguments = method_getNumberOfArguments(aMethod);
			if (numberOfArguments > 2)
			{
				NSArray *selectorComponents = [name componentsSeparatedByString:@":"];
				
				for (unsigned argumentIndex = 0; argumentIndex < numberOfArguments; argumentIndex++)
				{
					unsigned int charLength = 1024 * 4;
					char argumentTypeChar[charLength];
					method_getArgumentType(aMethod, argumentIndex, argumentTypeChar, charLength);
					
					if (argumentIndex > 1)
					{
						unsigned int adjustedArgumentIndex = argumentIndex - 2;
						
						if (argumentIndex > 2)
							[methodString appendString:@" "];
						
						[methodString appendString:selectorComponents[adjustedArgumentIndex]];
						[methodString appendString:@":("];
						
						NSString *argumentDescription = DALDescriptionOfReturnOrParameterType(argumentTypeChar);
						[methodString appendString:argumentDescription];
						
						[methodString appendFormat:@")arg%u", adjustedArgumentIndex+1];
					}
				}
			}
			else
			{
				[methodString appendString:name];
			}
			
			[methodString appendString:@";"];
			
			[array addObject:methodString];
		}
		return array;
	};
    
	NSArray *array = [arrayOfMethodsForClass(aClass, YES) arrayByAddingObjectsFromArray:arrayOfMethodsForClass(aClass, NO)];
	
	NSMutableString *description = [NSMutableString string];
	for (NSString *string in array)
	{
		[description appendFormat:@"%@\n", string];
	}
	
	if (array.count)
		[description deleteCharactersInRange:NSMakeRange(description.length - 1, 1)];
	
	return description;
}

NSString *DALClassPropertiesDescription(Class aClass)
{
	NSMutableArray *array = [NSMutableArray array];
	
	unsigned int numberOfProperties = 0;
	objc_property_t *properties = class_copyPropertyList(aClass, &numberOfProperties);
	for (unsigned int propertyIndex = 0; propertyIndex < numberOfProperties; propertyIndex++)
	{
		NSMutableString *description = [NSMutableString string];
		[description appendString:@"@property "];
		
		objc_property_t aProperty = properties[propertyIndex];
		const char *nameChar = property_getName(aProperty);
		NSString *name = [NSString stringWithUTF8String:nameChar];
		
		NSString *typeDescription;
		
		unsigned int numberOfAttributes = 0;
		objc_property_attribute_t *propertyAttributes = property_copyAttributeList(aProperty, &numberOfAttributes);
		
		if (numberOfAttributes > 1)
			[description appendString:@"("];
		
		for (unsigned int attributeIndex = 0; attributeIndex < numberOfAttributes; attributeIndex++)
		{
			objc_property_attribute_t anAttribute = propertyAttributes[attributeIndex];
			
			const char *name = anAttribute.name;
			if (name[0] == 'T' || name[0] == 't')
			{
				const char *value = anAttribute.value;
				if (value[0] == '@')
				{
					NSString *string = [NSString stringWithUTF8String:value];
					typeDescription = [string substringFromIndex:1];
					if (typeDescription.length > 1 && [typeDescription characterAtIndex:0] == '"' && [typeDescription characterAtIndex:typeDescription.length - 1] == '"')
					{
						typeDescription = [string substringWithRange:NSMakeRange(2, string.length - 3)];
						typeDescription = [typeDescription stringByAppendingString:@" *"];
					}
					else
					{
						typeDescription = [typeDescription stringByAppendingString:@" "];
					}
					
					if (!typeDescription)
						NSLog(@"");
				}
				else if (value[0] == '^')
				{
					typeDescription = [NSString stringWithUTF8String:value];
					
					if (!typeDescription)
						NSLog(@"");
				}
				else if (value[0] == '?')
				{
					typeDescription = [NSString stringWithUTF8String:value];
					
					if (!typeDescription)
						NSLog(@"");
				}
				else
				{
					typeDescription = DALDescriptionOfReturnOrParameterType(value);
					typeDescription = [typeDescription stringByAppendingString:@" "];
					if (!typeDescription)
						NSLog(@"");
				}
			}
			else
			{
				NSString *attributeDescription = DALDescriptionOfPropertyAttributeType(anAttribute);
				[description appendString:attributeDescription];
				
				if (attributeIndex < numberOfAttributes - 1)
					[description appendString:@", "];
			}
			
		}
		
		//TODO remove this hack and figure out propery when to add @", ".
		if ([description hasSuffix:@", "])
			[description deleteCharactersInRange:NSMakeRange(description.length - 1, 1)];
		
		if (numberOfAttributes > 1)
			[description appendString:@")"];
		
		[description appendString:@" "];
		[description appendString:typeDescription];
		[description appendString:name];
		[description appendString:@";"];
		
		[array addObject:description];
	}
	
	NSMutableString *description = [NSMutableString string];
	for (NSString *string in array)
	{
		[description appendFormat:@"%@\n", string];
	}
	
	if (array.count)
		[description deleteCharactersInRange:NSMakeRange(description.length - 1, 1)];
	
	return description;
}

#pragma mark Instance Introspection
NSString *DALInstanceIvarsDescription(id instance)
{
	NSMutableArray *array = [NSMutableArray array];
	
	NSInteger iterations = 0;
	Class currentClass = [instance class];
	NSString *prefixSpace = @"";
	while (currentClass)
	{
		NSMutableArray *currentClassProperties = [NSMutableArray array];
		NSString *currentClassNameDescription = [NSString stringWithFormat:@"%@%@%@ = {", prefixSpace, NSStringFromClass(currentClass), DALDescriptionOfProtocolsForClass(currentClass)];
		prefixSpace = [prefixSpace stringByAppendingString:@"\t"];
		
		unsigned int numberOfIvars = 0;
		Ivar *ivars = class_copyIvarList(currentClass, &numberOfIvars);
		for (unsigned int i = 0; i < numberOfIvars; i++)
		{
			NSMutableString *description = [NSMutableString string];
			
			Ivar anIvar = ivars[i];
			
//			const char *returnTypeChar = ivar_getTypeEncoding(anIvar);
//			NSString *returnTypeDescription = DALDescriptionOfReturnOrParameterType(returnTypeChar);
//			if ([returnTypeDescription hasPrefix:@"@\""] && [returnTypeDescription hasSuffix:@"\""])
//			{
//				returnTypeDescription = [returnTypeDescription substringWithRange:NSMakeRange(2, returnTypeDescription.length - 3)];
//				returnTypeDescription = [returnTypeDescription stringByAppendingString:@" *"];
//			}
//			else
//			{
//				returnTypeDescription = [returnTypeDescription stringByAppendingString:@" "];
//			}
			//
//			[description appendString:returnTypeDescription];
			
			const char *nameChar = ivar_getName(anIvar);
			NSString *name = [NSString stringWithUTF8String:nameChar];
			[description appendString:name];
			[description appendString:@" = "];
			
			NSString *valueDescription = DALDescriptionOfReturnValueForIvar(instance, anIvar);
			[description appendString:valueDescription];
			
			NSString *prefixedDescription = [prefixSpace stringByAppendingString:description];
			[currentClassProperties addObject:prefixedDescription];
		}
		
		[currentClassProperties sortUsingSelector:@selector(compare:)];
		[currentClassProperties insertObject:currentClassNameDescription atIndex:0];
		[currentClassProperties addObject:[[prefixSpace stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""] stringByAppendingString:@"}"]];
		[array insertObjects:currentClassProperties atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(iterations, currentClassProperties.count)]];
		
		iterations++;
		currentClass = [currentClass superclass];
	}
	
	NSMutableString *description = [NSMutableString string];
	for (NSString *string in array)
	{
		[description appendFormat:@"%@\n", string];
	}
	
	if (array.count)
		[description deleteCharactersInRange:NSMakeRange(description.length - 1, 1)];
	
	return description;
}

NSString *DALInstanceMethodsDescription(id instance)
{
	NSArray *(^arrayOfMethodsForClass)(Class aClass, BOOL useMetaClass, NSString *prefix) = ^NSArray *(Class aClass, BOOL useMetaClass, NSString *prefix) {
		
		NSMutableArray *array = [NSMutableArray array];
		
		if (useMetaClass)
			aClass = objc_getMetaClass(class_getName(aClass));
		
		unsigned int numberOfMethods;
		Method *classMethods = class_copyMethodList(aClass, &numberOfMethods);
		
		for (unsigned int methodIndex = 0; methodIndex < numberOfMethods; methodIndex++)
		{
			NSMutableString *methodString = [NSMutableString string];
			
			Method aMethod = classMethods[methodIndex];
			SEL selector = method_getName(aMethod);
			NSString *name = NSStringFromSelector(selector);
			
			[methodString appendString:prefix];
			
			// method type (class or instance)
			if (useMetaClass)
				[methodString appendString:@"+"];
			else
				[methodString appendString:@"-"];
			
			// return type
			[methodString appendString:@" ("];
			
			unsigned int charLength = 1024 * 4;
			char returnTypeChar[charLength];
			method_getReturnType(aMethod, returnTypeChar, charLength);
			NSString *returnTypeDescription = DALDescriptionOfReturnOrParameterType(returnTypeChar);
			if ([returnTypeDescription isEqualToString:@"id"] &&
				( (useMetaClass && [name hasPrefix:@"new"]) || (!useMetaClass && [name hasPrefix:@"init"]) ) )
			{
				returnTypeDescription = @"instancetype";
			}
			
			[methodString appendString:returnTypeDescription];
			
			[methodString appendString:@")"];
			
			unsigned numberOfArguments = method_getNumberOfArguments(aMethod);
			if (numberOfArguments > 2)
			{
				NSArray *selectorComponents = [name componentsSeparatedByString:@":"];
				
				for (unsigned argumentIndex = 2; argumentIndex < numberOfArguments; argumentIndex++)
				{
					unsigned parameterIndex = argumentIndex - 2;
					
					if (parameterIndex)
						[methodString appendString:@" "];
					
					[methodString appendString:selectorComponents[parameterIndex]];
					[methodString appendString:@":("];
					
					unsigned int charLength = 1024 * 4;
					char argumentTypeChar[charLength];
					method_getArgumentType(aMethod, parameterIndex, argumentTypeChar, charLength);
					NSString *argumentDescription = DALDescriptionOfReturnOrParameterType(argumentTypeChar);
					[methodString appendString:argumentDescription];
					
					[methodString appendFormat:@")arg%i", parameterIndex+1];
				}
			}
			else
			{
				[methodString appendString:name];
			}
			
			if (!useMetaClass && returnTypeChar[0] != _C_VOID && numberOfArguments == 2 && !DALShouldIgnoreMethod(aMethod))
			{
				[methodString appendString:@" = "];
				id theSelf = useMetaClass ? aClass : instance;
				
				NSString *returnValue = nil;
				@try {
					returnValue = DALDescriptionOfReturnValueFromMethod(theSelf, aMethod);
				}
				@catch (NSException *exception) {
					returnValue = [[exception reason] substringFromIndex:([[exception reason] rangeOfString:@":"].location + 2)];
				}
				
				[methodString appendString:returnValue];
			}
			
			[array addObject:methodString];
		}
		return array;
	};
    
	
	NSMutableArray *array = [NSMutableArray array];
	
	NSInteger iterations = 0;
	Class currentClass = [instance class];
	NSString *prefixSpace = @"";
	while (currentClass)
	{
		NSMutableArray *currentMethods = [NSMutableArray array];
		NSString *currentClassNameDescription = [NSString stringWithFormat:@"%@%@ %@ = {", prefixSpace, NSStringFromClass(currentClass), DALDescriptionOfProtocolsForClass(currentClass)];
		prefixSpace = [prefixSpace stringByAppendingString:@"\t"];
		
		NSArray *classMethods = arrayOfMethodsForClass(currentClass, YES, prefixSpace);
		[currentMethods addObjectsFromArray:classMethods];
		NSArray *instanceMethods = arrayOfMethodsForClass(currentClass, NO, prefixSpace);
		[currentMethods addObjectsFromArray:instanceMethods];
		[currentMethods insertObject:currentClassNameDescription atIndex:0];
		[currentMethods addObject:[[prefixSpace stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""] stringByAppendingString:@"}"]];
		[array insertObjects:currentMethods atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(iterations, currentMethods.count)]];
		
		iterations++;
		currentClass = [currentClass superclass];
	}
	
	NSMutableString *description = [NSMutableString string];
	for (NSString *string in array)
	{
		[description appendFormat:@"%@\n", string];
	}
	
	if (array.count)
		[description deleteCharactersInRange:NSMakeRange(description.length - 1, 1)];
	
	return description;
}

NSString *DALInstancePropertiesDescription(id instance)
{
	NSMutableArray *array = [NSMutableArray array];
	
	NSInteger iterations = 0;
	Class currentClass = [instance class];
	NSString *prefixSpace = @"";
	while (currentClass)
	{
		NSMutableArray *currentClassProperties = [NSMutableArray array];
		NSString *currentClassNameDescription = [NSString stringWithFormat:@"%@%@ %@ = {", prefixSpace, NSStringFromClass(currentClass), DALDescriptionOfProtocolsForClass(currentClass)];
		prefixSpace = [prefixSpace stringByAppendingString:@"\t"];
		
		unsigned int numberOfProperties = 0;
		objc_property_t *properties = class_copyPropertyList(currentClass, &numberOfProperties);
		for (unsigned int propertyIndex = 0; propertyIndex < numberOfProperties; propertyIndex++)
		{
			NSMutableString *description = [NSMutableString string];
			
			objc_property_t aProperty = properties[propertyIndex];
			const char *nameChar = property_getName(aProperty);
			NSString *name = [NSString stringWithUTF8String:nameChar];
			[description appendString:@"self."];
			[description appendString:name];
			[description appendString:@" = "];
			
			SEL getterSEL = DALSelectorForPropertyOfClass(aProperty, currentClass);
			Method getterMethod = class_getInstanceMethod(currentClass, getterSEL);
			
			NSString *valueDescription = DALDescriptionOfReturnValueFromMethod(instance, getterMethod);
			[description appendString:valueDescription];
			
			NSString *prefixedDescription = [prefixSpace stringByAppendingString:description];
			[currentClassProperties addObject:prefixedDescription];
		}
		
		[currentClassProperties sortUsingSelector:@selector(compare:)];
		[currentClassProperties insertObject:currentClassNameDescription atIndex:0];
		[currentClassProperties addObject:[[prefixSpace stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""] stringByAppendingString:@"}"]];
		[array insertObjects:currentClassProperties atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(iterations, currentClassProperties.count)]];
		
		iterations++;
		currentClass = [currentClass superclass];
	}
	
	NSMutableString *description = [NSMutableString string];
	for (NSString *string in array)
	{
		[description appendFormat:@"%@\n", string];
	}
	
	if (array.count)
		[description deleteCharactersInRange:NSMakeRange(description.length - 1, 1)];
	
	return description;
}

#pragma mark Protocol Introspection
NSString *DALProtocolDescription(Protocol *aProtocol)
{
	return @"Not yet implemented...";
}

#pragma mark -
#pragma mark Convenience
id KeyWindowDescription()
{
	return [[[UIApplication sharedApplication] keyWindow] recursiveDescription];
}

#pragma mark -
#pragma mark Swizzling Introspection
NSString *DALDescriptionOfProtocolsForClass(Class aClass)
{
	NSMutableString *description = [NSMutableString string];
	
	unsigned int numberOfProtocols = 0;
	Protocol * __unsafe_unretained *protocols = class_copyProtocolList(aClass, &numberOfProtocols);
	if (numberOfProtocols)
	{
		[description appendString:@"<"];
		
		for (unsigned int i = 0; i < numberOfProtocols; i++)
		{
			if (i > 0)
				[description appendString:@", "];
			
			Protocol *aProtocol = protocols[i];
			const char *nameChar = protocol_getName(aProtocol);
			NSString *name = [NSString stringWithUTF8String:nameChar];
			[description appendString:name];
		}
		
		[description appendString:@">"];
	}
	
	return description;
};


#pragma mark -
#pragma mark -
#pragma mark Helpers
NSString *DALDescriptionOfReturnOrParameterType(const char *type)
{
	NSString *description;
	
	if (strlen(type) > 1)
	{
		description = [NSString stringWithUTF8String:type];
		if (!description)
		{
			description = [NSString stringWithFormat:@"%s", type];
			NSLog(@"Error! description is nil.");
		}
	}
	else
	{
		switch (type[0])
		{
			case _C_ID:       // '@'
				description = @"id";
				break;
			case _C_CLASS:    // '#'
				description = @"Class";
				break;
			case _C_SEL:      // ':'
				description = @"SEL";
				break;
			case _C_CHR:      // 'c'
				description = @"BOOL";
				break;
			case _C_UCHR:     // 'C'
				description = @"unsigned char";
				break;
			case _C_SHT:      // 's'
				description = @"short";
				break;
			case _C_USHT:     // 'S'
				description = @"unsigned short";
				break;
			case _C_INT:      // 'i'
				description = @"int";
				break;
			case _C_UINT:     // 'I'
				description = @"unsigned int";
				break;
			case _C_LNG:      // 'l'
				description = @"long";
				break;
			case _C_ULNG:     // 'L'
				description = @"unsigned long";
				break;
			case _C_LNG_LNG:  // 'q'
				description = @"long long";
				break;
			case _C_ULNG_LNG: // 'Q'
				description = @"unsigned long long";
				break;
			case _C_FLT:      // 'f'
				description = @"float";
				break;
			case _C_DBL:      // 'd'
				description = @"double";
				break;
			case _C_BFLD:     // 'b'
				description = @"'b' _C_BFLD";
				break;
			case _C_BOOL:     // 'B'
				description = @"BOOL";
				break;
			case _C_VOID:     // 'v'
				description = @"void";
				break;
			case _C_UNDEF:    // '?'
				description = @"'?' _C_UNDEF";
				break;
			case _C_PTR:      // '^'
				description = @"'^' _C_PTR";
				break;
			case _C_CHARPTR:  // '*'
				description = @"(const) char *";
				break;
			case _C_ATOM:     // '%'
				description = @"'%' _C_ATOM";
				break;
			case _C_ARY_B:    // '['
				description = @"'[' _C_ARY_B";
				break;
			case _C_ARY_E:    // ']'
				description = @"']' _C_ARY_E";
				break;
			case _C_UNION_B:  // '('
				description = @"'(' _C_UNION_B";
				break;
			case _C_UNION_E:  // ')'
				description = @"')' _C_UNION_E";
				break;
			case _C_STRUCT_B: // '{'
				description = @"'{' _C_STRUCT_B";
				break;
			case _C_STRUCT_E: // '}'
				description = @"'}' _C_STRUCT_E";
				break;
			case _C_VECTOR:   // '!'
				description = @"'!' _C_VECTOR";
				break;
			case _C_CONST:    // 'r'
				description = @"'r' _C_CONST";
				break;
			case 0:
				description = @"(null)";
				break;
				
			case 'D': // +[PFUbiquityBaseline requiredFractionOfDiskSpaceUsedForLogs];
			case 'R': // -[_UIViewServiceSession __requestConnectionToDeputyOfClass:fromHostObject:replyHandler:];
				description = [NSString stringWithFormat:@"Unknown type: %s", type];
				break;
				
			default:
				description = [NSString stringWithFormat:@"Unknown type: %s", type];
				break;
		}
	}
	
	return description;
}

NSString *DALDescriptionOfPropertyAttributeType(objc_property_attribute_t attribute)
{
	NSString *description;
	
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
			description = [NSString stringWithFormat:@"getter = %s", value];
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
			description = [NSString stringWithFormat:@"setter = %s", value];
			break;
		case 'T':
		case 't':
			description = [NSString stringWithFormat:@"type = %s", value];
			break;
		case 'V':
			description = @"";
			break;
		case 'W':
			description = @"weak";
			break;
		case '&':
			description = @"retain";
			break;
		case 0:
			description = @"(null)";
			break;
			
		default:
			description = [NSString stringWithFormat:@"Unknown type: %s", name];
			break;
	}
	
	return description;
}

NSString *DALBinaryRepresentationOfNSInteger(NSInteger anInteger)
{
    NSMutableString * string = [[NSMutableString alloc] init];
	
    NSInteger spacing = pow(2, 3);
    NSInteger width = sizeof(anInteger) * spacing;
    NSInteger binaryDigit = 0;
    NSInteger integer = anInteger;
	
    while (binaryDigit < width)
    {
        binaryDigit++;
		
		NSString *digit = (integer & 1) ? @"1" : @"0";
        [string insertString:digit atIndex:0];
		
        if ( (binaryDigit % spacing == 0) && (binaryDigit != width) )
        {
            [string insertString:@" " atIndex:0];
        }
		
        integer = integer >> 1;
    }
	
    return string;
}

NSString *DALBinaryRepresentationOfNSUInteger(NSUInteger anUnsignedInteger)
{
    NSMutableString * string = [[NSMutableString alloc] init];
	
    NSUInteger spacing = pow(2, 3);
    NSUInteger width = sizeof(anUnsignedInteger) * spacing;
    NSUInteger binaryDigit = 0;
    NSUInteger integer = anUnsignedInteger;
	
    while (binaryDigit < width)
    {
        binaryDigit++;
		
		NSString *digit = (integer & 1) ? @"1" : @"0";
        [string insertString:digit atIndex:0];
		
        if ( (binaryDigit % spacing == 0) && (binaryDigit != width) )
        {
            [string insertString:@" " atIndex:0];
        }
		
        integer = integer >> 1;
    }
	
    return string;
}

NSDictionary *DALPropertyNamesAndValuesMemoryAddressesForObject(NSObject *instance)
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	
	Class theClass = [instance class];
	while (theClass)
	{
		unsigned int numberOfProperties = 0;
		objc_property_t *properties = class_copyPropertyList(theClass, &numberOfProperties);
		for (unsigned int i = 0; i < numberOfProperties; i++)
		{
			objc_property_t property = properties[i];
			
			char *attributeValueType = property_copyAttributeValue(property, "T");
			if (attributeValueType[0] == '@')
			{
				const char *propertyNameChar = property_getName(property);
				NSString *name = [NSString stringWithFormat:@"%s", propertyNameChar];
				
				id propertyValue = nil;
				NSString *selectorString = name;
				
				char *customGetterChar = property_copyAttributeValue(property, "G");
				if (customGetterChar && strlen(customGetterChar) > 0)
					selectorString = [NSString stringWithFormat:@"%s", customGetterChar];
				
				SEL selector = NSSelectorFromString(selectorString);
                
                // The following try/catch is to prevent this function from failing due to an assert throwing an exception.
                @try
                {
                    propertyValue = objc_msgSend(instance, selector);
                }
                @catch (NSException *exception)
                {
                }
                
				if (propertyValue)
				{
					NSString *key = [NSString stringWithFormat:@"%@ in class %@", name, NSStringFromClass(theClass)];
					NSString *valueMemoryAddress = [NSString stringWithFormat:@"%p", propertyValue];
					dictionary[key] = valueMemoryAddress;
				}
			}
		}
		
		theClass = [theClass superclass];
	}
	
	return dictionary;
}

SEL DALSelectorForPropertyOfClass(objc_property_t property, Class aClass)
{
	SEL selector = nil;
	
	// Get attributes
	unsigned int numberOfAttributes = 0;
	objc_property_attribute_t *propertyAttributes = property_copyAttributeList(property, &numberOfAttributes);
	for (unsigned int attributeIndex = 0; attributeIndex < numberOfAttributes; attributeIndex++)
	{
		objc_property_attribute_t anAttribute = propertyAttributes[attributeIndex];
		if (anAttribute.name[0] == 'G')
		{
			const char *value = anAttribute.value;
			NSString *selectorString = [NSString stringWithUTF8String:value];
			selector = NSSelectorFromString(selectorString);
		}
	}
	
	// If no custom getter, use default (this is a slight optimization over setting it initially)
	if (!selector)
	{
		const char *name = property_getName(property);
		NSString *getterString = [NSString stringWithUTF8String:name];
		selector = NSSelectorFromString(getterString);
	}
	
	return selector;
}

#endif
