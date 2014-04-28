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
		
		//TODO remove this hack and figure out properly when to add @", ".
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
			
			//const char *returnTypeChar = ivar_getTypeEncoding(anIvar);
			//NSString *returnTypeDescription = DALDescriptionOfReturnOrParameterType(returnTypeChar);
			//if ([returnTypeDescription hasPrefix:@"@\""] && [returnTypeDescription hasSuffix:@"\""])
			//{
			//	returnTypeDescription = [returnTypeDescription substringWithRange:NSMakeRange(2, returnTypeDescription.length - 3)];
			//	returnTypeDescription = [returnTypeDescription stringByAppendingString:@" *"];
			//}
			//else
			//{
			//	returnTypeDescription = [returnTypeDescription stringByAppendingString:@" "];
			//}
			//
			//[description appendString:returnTypeDescription];
			
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
//			if ([returnTypeDescription isEqualToString:@"id"] &&
//				( (useMetaClass && [name hasPrefix:@"new"]) || (!useMetaClass && [name hasPrefix:@"init"]) ) )
//			{
//				returnTypeDescription = @"instancetype";
//			}
			
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
			
			if (!useMetaClass && returnTypeChar[0] != _C_VOID && numberOfArguments == 2)
			{
				[methodString appendString:@" = "];
				
				if (DALShouldIgnoreMethod(aMethod))
				{
					[methodString appendString:@"(ignored)"];
				}
				else
				{
					id theSelf = useMetaClass ? aClass : instance;
					
					NSString *returnValue = nil;
					@try
					{
						returnValue = DALDescriptionOfReturnValueFromMethod(theSelf, aMethod);
					}
					@catch (NSException *exception)
					{
						returnValue = [NSString stringWithFormat:@"(%@ (%@))", [exception reason], [exception name]];
					}
					
					[methodString appendString:returnValue ?: @""];
				}
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

NSDictionary *DALInstancePropertyNamesInNextResponderChainOfInstance(NSObject *instance)
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
					propertyValue = [instance valueForKey:name];
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

#pragma mark Protocol Introspection
NSString *DALProtocolDescription(Protocol *aProtocol)
{
	return @"Not yet implemented...";
}

#pragma mark - Convenience

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
	if ([string hasPrefix:@"create"] ||
		[string hasPrefix:@"initWith"] ||
		[string hasPrefix:@"new"] ||
		// Begin my category methods that should be ignored
		[string isEqualToString:@"ancestryDescription"] ||
		[string isEqualToString:@"ancestryWithProtocolsDescription"] ||
		[string isEqualToString:@"ivarsDescription"] ||
		[string isEqualToString:@"methodsDescription"] ||
		[string isEqualToString:@"propertiesDescription"] ||
		[string isEqualToString:@"DAL_description"] ||
		[string isEqualToString:@"propertyNames"] ||
		[string isEqualToString:@"DAL_saveToDocuments"] ||
		[string isEqualToString:@"DAL_documentsPath"] ||
		[string isEqualToString:@"enableSlowAnimations"] ||
		[string isEqualToString:@"disableSlowAnimations"] ||
		// End my category methods that should be ignored
		[string isEqualToString:@".cxx_destruct"] ||
		[string isEqualToString:@"___tryRetain_OA"] ||
		[string isEqualToString:@"__autorelease_OA"] ||
		[string isEqualToString:@"__dealloc_zombie"] ||
		[string isEqualToString:@"__release_OA"] ||
		[string isEqualToString:@"__retain_OA"] ||
		[string isEqualToString:@"_caretRect"] ||
		[string isEqualToString:@"_characterBeforeCaretSelection"] ||
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
		[string hasSuffix:@"Copy"] ||
		[string hasSuffix:@"Release"] ||
		[string hasSuffix:@"Retain"] ||
		[string rangeOfString:@"_copy"].location != NSNotFound)
	{
		shouldIgnoreSelector = YES;
	}
	
	return shouldIgnoreSelector;
}

#pragma mark Descriptions

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
				description = @"bitfield";
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

/// \brief Will ignore Methods that take parameters
NSString *DALDescriptionOfReturnValueFromMethod(id instance, Method aMethod)
{
	SEL aSelector = method_getName(aMethod);
	
	int returnTypeLength = 1024 * 10;
	char returnTypeChar[returnTypeLength];
	
	method_getReturnType(aMethod, returnTypeChar, returnTypeLength);
	
	u_int numberOfArguments = method_getNumberOfArguments(aMethod);
	if (numberOfArguments > 2)
	{
		return [NSString stringWithFormat:@"(ignoring method: %@)", NSStringFromSelector(method_getName(aMethod))];
	}
	
	NSString *description = nil;
	switch (returnTypeChar[0])
	{
		case _C_ID:       // '@'
		{
			id result = nil;
			result = objc_msgSend(instance, aSelector);
			description = DALDescriptionOfFoundationObject(result);
		}
			break;
			
		case _C_CLASS:    // '#'
		{
			Class result = NULL;
			
			Class (*DAL_Class_object_msgSend)(id, SEL) = (Class (*)(id, SEL))objc_msgSend;
			result = DAL_Class_object_msgSend(instance, aSelector);
			
			if (result)
			{
				description = NSStringFromClass(result);
			}
		}
			break;
			
		case _C_SEL:      // ':'
		{
			SEL result = NULL;
			
			SEL (*DAL_SEL_objc_msgSend)(id, SEL) = (SEL(*)(id, SEL))objc_msgSend;
			result = DAL_SEL_objc_msgSend(instance, aSelector);
			
			if (result)
			{
				description = NSStringFromSelector(result);
			}
		}
			break;
			
		case _C_CHR:      // 'c' // BOOL is usually type'd as a char
		{
			char result = 0;
			
			char (*DAL_char_objc_msgSend)(id, SEL) = (char (*)(id, SEL))objc_msgSend;
			result = DAL_char_objc_msgSend(instance, aSelector);
			
			description = [NSString stringWithFormat:@"%hhd", result];
		}
			break;
			
		case _C_UCHR:     // 'C'
		{
			unsigned char result = 0;

			unsigned char (*DAL_unsigned_char_objc_msgSend)(id, SEL) = (unsigned char (*)(id, SEL))objc_msgSend;
			result = DAL_unsigned_char_objc_msgSend(instance, aSelector);

			description = [NSString stringWithFormat:@"%hhu", result];
		}
			break;
			
		case _C_SHT:      // 's'
		{
			short result = 0;

			short (*DAL_short_objc_msgSend)(id, SEL) = (short (*)(id, SEL))objc_msgSend;
			result = DAL_short_objc_msgSend(instance, aSelector);

			description = [NSString stringWithFormat:@"%hd", result];
		}
			break;
			
		case _C_USHT:     // 'S'
		{
			unsigned short result = 0;

			unsigned short (*DAL_unsignedShort_objc_msgSend)(id, SEL) = (unsigned short (*)(id, SEL))objc_msgSend;
			result = DAL_unsignedShort_objc_msgSend(instance, aSelector);

			description = [NSString stringWithFormat:@"%hu", result];
		}
			break;
			
		case _C_INT:      // 'i'
		{
			int result = 0;

			int (*DAL_int_objc_msgSend)(id, SEL) = (int (*)(id, SEL))objc_msgSend;
			result = DAL_int_objc_msgSend(instance, aSelector);

			description = [NSString stringWithFormat:@"%d", result];
		}
			break;
			
		case _C_UINT:     // 'I'
		{
			unsigned int result = 0;

			unsigned int (*DAL_unsigned_int_objc_msgSend)(id, SEL) = (unsigned int (*)(id, SEL))objc_msgSend;
			result = DAL_unsigned_int_objc_msgSend(instance, aSelector);

			description = [NSString stringWithFormat:@"%u", result];
		}
			break;
			
		case _C_LNG:      // 'l'
		{
			long result = 0;

			long (*DAL_long_objc_msgSend)(id, SEL) = (long (*)(id, SEL))objc_msgSend;
			result = DAL_long_objc_msgSend(instance, aSelector);

			description = [NSString stringWithFormat:@"%ld", result];
		}
			break;
			
		case _C_ULNG:     // 'L'
		{
			unsigned long result = 0;

			unsigned long (*DAL_unsigned_long_objc_msgSend)(id, SEL) = (unsigned long (*)(id, SEL))objc_msgSend;
			result = DAL_unsigned_long_objc_msgSend(instance, aSelector);

			description = [NSString stringWithFormat:@"%lu", result];
		}
			break;
			
		case _C_LNG_LNG:  // 'q'
		{
			long long result = 0;
			
			long long (*DAL_long_long_objc_msgSend)(id, SEL) = (long long (*)(id, SEL))objc_msgSend;
			result = DAL_long_long_objc_msgSend(instance, aSelector);
			
			description = [NSString stringWithFormat:@"%lld", result];
		}
			break;
			
		case _C_ULNG_LNG: // 'Q'
		{
			unsigned long long result = 0;
			
			unsigned long long (*DAL_unsigned_long_long_objc_msgSend)(id, SEL) = (unsigned long long (*)(id, SEL))objc_msgSend;
			result = DAL_unsigned_long_long_objc_msgSend(instance, aSelector);
			
			description = [NSString stringWithFormat:@"%llu", result];
		}
			break;
			
		case _C_FLT:      // 'f'
        {
			float result = 0;
			
			float (*DAL_float_objc_msgSend)(id, SEL) = (float (*)(id, SEL))objc_msgSend;
			result = DAL_float_objc_msgSend(instance, aSelector);
			
			description = [NSString stringWithFormat:@"%f", result];
        }
			break;
			
		case _C_DBL:      // 'd'
        {
			double result = 0;
			
			double (*DAL_double_objc_msgSend)(id, SEL) = (double (*)(id, SEL))objc_msgSend;
			result = DAL_double_objc_msgSend(instance, aSelector);
			
			description = [NSString stringWithFormat:@"%f", result];
        }
			break;
			
		case _C_BFLD:     // 'b'
		{
			NSUInteger result;

			NSUInteger (*DAL_NSUInteger_objc_msgSend)(id, SEL) = (NSUInteger (*)(id, SEL))objc_msgSend;
			result = DAL_NSUInteger_objc_msgSend(instance, aSelector);

			description = DALBinaryRepresentationOfNSUInteger(result);
		}
			break;
			
		case _C_BOOL:     // 'B'
		{
			BOOL result = NO;

			BOOL (*DAL_BOOL_objc_msgSend)(id, SEL) = (BOOL (*)(id, SEL))objc_msgSend;
			result = DAL_BOOL_objc_msgSend(instance, aSelector);

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
					if ([returnType isEqualToString:@"^{__CFArray=}"])
					{
						CFArrayRef result = NULL;
						
						CFArrayRef (*DAL_CFArrayRef_objc_msgSend)(id, SEL) = (CFArrayRef (*)(id, SEL))objc_msgSend;
						result = DAL_CFArrayRef_objc_msgSend(instance, aSelector);
						
						NSArray *array = (__bridge NSArray *)(result);
						description = DALDescriptionOfFoundationObject(array);
					}
					else if ([returnType isEqualToString:@"^{__CFDictionary=}"])
					{
						CFDictionaryRef result = NULL;
						
						CFDictionaryRef (*DAL_CFDictionaryRef_objc_msgSend)(id, SEL) = (CFDictionaryRef (*)(id, SEL))objc_msgSend;
						result = DAL_CFDictionaryRef_objc_msgSend(instance, aSelector);
						
						NSDictionary *dictionary = (__bridge NSDictionary *)(result);
						description = DALDescriptionOfFoundationObject(dictionary);
					}
					else if ([returnType isEqualToString:@"^{_NSZone=}"])
					{
						description = DALDescriptionForUnsupportedType(returnTypeChar);
					}
					else if ([returnType isEqualToString:@"^{CGColor=}"])
					{
						CGColorRef result = NULL;
						
						CGColorRef (*DAL_CGColorRef_objc_msgSend)(id, SEL) = (CGColorRef (*)(id, SEL))objc_msgSend;
						result = DAL_CGColorRef_objc_msgSend(instance, aSelector);
						
						UIColor *color = [UIColor colorWithCGColor:result];
						description = DALDescriptionOfFoundationObject(color);
					}
					else if ([returnType isEqualToString:@"^{CGPath=}"])
					{
						CGPathRef result = NULL;
						
						CGPathRef (*DAL_CGPathRef_objc_msgSend)(id, SEL) = (CGPathRef (*)(id, SEL))objc_msgSend;
						result = DAL_CGPathRef_objc_msgSend(instance, aSelector);
						
						if (result)
						{
							UIBezierPath *bezierPath = [UIBezierPath bezierPathWithCGPath:result];
							description = DALDescriptionOfFoundationObject(bezierPath);
						}
					}
					else
					{
						description = DALDescriptionForUnsupportedType(returnTypeChar);
					}
				}
					break;
					
				case 'v':
				{
					void *result = NULL;
					
					void *(*DAL_void_star_objc_msgSend)(id, SEL) = (void *(*)(id, SEL))objc_msgSend;
					result = DAL_void_star_objc_msgSend(instance, aSelector);
					
					description = [NSString stringWithFormat:@"%p", result];
				}
					break;
					
				default:
					description = DALDescriptionForUnsupportedType(returnTypeChar);
					break;
			}
		}
			break;
			
		case _C_CHARPTR:  // '*'
		{
			char *result;
			
			char *(*DAL_char_star_objc_msgSend)(id, SEL) = (char *(*)(id, SEL))objc_msgSend;
			result = DAL_char_star_objc_msgSend(instance, aSelector);
			
			description = [NSString stringWithUTF8String:result];
		}
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
			if ([typeString hasPrefix:@"{CGPoint="])
			{
				CGPoint result = CGPointZero;
				
				CGPoint (*DAL_CGPoint_objc_msgSend)(id, SEL) = (CGPoint (*)(id, SEL))objc_msgSend;
				result = DAL_CGPoint_objc_msgSend(instance, aSelector);
				
				description = NSStringFromCGPoint(result);
			}
			else if ([typeString hasPrefix:@"{CGSize="])
			{
				CGSize result = CGSizeZero;
				
				CGSize (*DAL_CGSize_objc_msgSend)(id, SEL) = (CGSize (*)(id, SEL))objc_msgSend;
				result = DAL_CGSize_objc_msgSend(instance, aSelector);

				description = NSStringFromCGSize(result);
			}
			else if ([typeString hasPrefix:@"{CGRect="])
			{
				CGRect result = CGRectZero;
				
				CGRect (*DAL_CGRect_objc_msgSend)(id, SEL) = (CGRect (*)(id, SEL))objc_msgSend;
				result = DAL_CGRect_objc_msgSend(instance, aSelector);
				
				description = NSStringFromCGRect(result);
			}
			else if ([typeString hasPrefix:@"{UIEdgeInsets="])
			{
				UIEdgeInsets result = UIEdgeInsetsZero;
				
				UIEdgeInsets (*DAL_UIEdgeInsets_objc_msgSend)(id, SEL) = (UIEdgeInsets (*)(id, SEL))objc_msgSend;
				result = DAL_UIEdgeInsets_objc_msgSend(instance, aSelector);
				
				description = NSStringFromUIEdgeInsets(result);
			}
			else if ([typeString hasPrefix:@"{CGAffineTransform="])
			{
				CGAffineTransform result = CGAffineTransformIdentity;
				
				CGAffineTransform (*DAL_CGAffineTransform_objc_msgSend)(id, SEL) = (CGAffineTransform (*)(id, SEL))objc_msgSend;
				result = DAL_CGAffineTransform_objc_msgSend(instance, aSelector);
				
				description = NSStringFromCGAffineTransform(result);
			}
			else if ([typeString hasPrefix:@"{CATransform3D="])
			{
				CATransform3D result = CATransform3DIdentity;
				
				CATransform3D (*DAL_CATransform3D_objc_msgSend)(id, SEL) = (CATransform3D (*)(id, SEL))objc_msgSend;
				result = DAL_CATransform3D_objc_msgSend(instance, aSelector);
				
				description = DALDescriptionOfCATransform3D(result);
			}
			else
			{
			// TODO: Implement creating description for struct
			// ^ See other TODO
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
			
			const char *(*DAL_const_char_star_objc_msgSend)(id, SEL) = (const char *(*)(id, SEL))objc_msgSend;
			result = DAL_const_char_star_objc_msgSend(instance, aSelector);
			
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

NSString *DALDescriptionOfReturnValueForIvar(id instance, Ivar anIvar)
{
	NSString *description = nil;
	
	const char *returnTypeChar = ivar_getTypeEncoding(anIvar);
	switch (returnTypeChar[0])
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
			
			// Hack, because the value grabbed directly from 'isa' (on Arm 64-bit) can't be used.
			if ([@(ivar_getName(anIvar)) isEqualToString:@"isa"])
			{
				description = @(class_getName(object_getClass(instance)));
			}
			else
			{
				Class (*DAL_Class_object_getIvar)(id, Ivar) = (Class (*)(id, Ivar))object_getIvar;
				result = DAL_Class_object_getIvar(instance, anIvar);
				
				if (result)
				{
					description = NSStringFromClass(result);
				}
			}
		}
			break;
			
		case _C_SEL:      // ':'
		{
			SEL result = NULL;
			
			SEL (*DAL_SEL_object_getIvar)(id, Ivar) = (SEL (*)(id, Ivar))object_getIvar;
			result = DAL_SEL_object_getIvar(instance, anIvar);
			
			if (result)
			{
				description = NSStringFromSelector(result);
			}
		}
			break;
			
		case _C_CHR:      // 'c' // BOOL is usually type'd as a char
		{
			char result = 0;
			
			char (*DAL_char_object_getIvar)(id, Ivar) = (char (*)(id, Ivar))object_getIvar;
			result = DAL_char_object_getIvar(instance, anIvar);
			
			description = [NSString stringWithFormat:@"%hhd", result];
		}
			break;
			
			
		case _C_UCHR:     // 'C'
		{
			unsigned char result = 0;
			
			unsigned char (*DAL_unsigned_char_object_getIvar)(id, Ivar) = (unsigned char (*)(id, Ivar))object_getIvar;
			result = DAL_unsigned_char_object_getIvar(instance, anIvar);
			
			description = [NSString stringWithFormat:@"%hhu", result];
		}
			break;
			
		case _C_SHT:      // 's'
		{
			short result = 0;
			
			short (*DAL_short_object_getIvar)(id, Ivar) = (short (*)(id, Ivar))object_getIvar;
			result = DAL_short_object_getIvar(instance, anIvar);
			
			description = [NSString stringWithFormat:@"%hd", result];
		}
			break;
			
		case _C_USHT:     // 'S'
		{
			unsigned short result = 0;
			
			unsigned short (*DAL_unsigned_short_object_getIvar)(id, Ivar) = (unsigned short (*)(id, Ivar))object_getIvar;
			result = DAL_unsigned_short_object_getIvar(instance, anIvar);
			
			description = [NSString stringWithFormat:@"%hu", result];
		}
			break;
			
		case _C_INT:      // 'i'
		{
			int result = 0;
			
			int (*DAL_int_object_getIvar)(id, Ivar) = (int (*)(id, Ivar))object_getIvar;
			result = DAL_int_object_getIvar(instance, anIvar);
			
			description = [NSString stringWithFormat:@"%d", result];
		}
			break;
			
		case _C_UINT:     // 'I'
		{
			unsigned int result = 0;
			
			unsigned int (*DAL_unsigned_int_object_getIvar)(id, Ivar) = (unsigned int (*)(id, Ivar))object_getIvar;
			result = DAL_unsigned_int_object_getIvar(instance, anIvar);
			
			description = [NSString stringWithFormat:@"%u", result];
		}
			break;
			
		case _C_LNG:      // 'l'
		{
			long result = 0;
			
			long (*DAL_long_object_getIvar)(id, Ivar) = (long (*)(id, Ivar))object_getIvar;
			result = DAL_long_object_getIvar(instance, anIvar);
			
			description = [NSString stringWithFormat:@"%ld", result];
		}
			break;
			
		case _C_ULNG:     // 'L'
		{
			unsigned long result = 0;
			
			unsigned long (*DAL_unsigned_long_object_getIvar)(id, Ivar) = (unsigned long (*)(id, Ivar))object_getIvar;
			result = DAL_unsigned_long_object_getIvar(instance, anIvar);
			
			description = [NSString stringWithFormat:@"%lu", result];
		}
			break;
			
		case _C_LNG_LNG:  // 'q'
		{
			long long result = 0;
			
			long long (*DAL_long_long_object_getIvar)(id, Ivar) = (long long (*)(id, Ivar))object_getIvar;
			result = DAL_long_long_object_getIvar(instance, anIvar);
			
			description = [NSString stringWithFormat:@"%qd", result];
		}
			break;
			
		case _C_ULNG_LNG: // 'Q'
		{
			unsigned long long result = 0;
			
			unsigned long long (*DAL_unsigned_long_long_object_getIvar)(id, Ivar) = (unsigned long long (*)(id, Ivar))object_getIvar;
			result = DAL_unsigned_long_long_object_getIvar(instance, anIvar);
			
			description = [NSString stringWithFormat:@"%qu", result];
		}
			break;
			
		case _C_FLT:      // 'f'
		{
			float result = 0;
			
			float (*DAL_float_object_getIvar)(id, Ivar) = (float (*)(id, Ivar))object_getIvar;
			result = DAL_float_object_getIvar(instance, anIvar);
			
			description = [NSString stringWithFormat:@"%f", result];
		}
			break;
			
		case _C_DBL:      // 'd'
		{
			double result = 0;
			
			double (*DAL_double_object_getIvar)(id, Ivar) = (double (*)(id, Ivar))object_getIvar;
			result = DAL_double_object_getIvar(instance, anIvar);
			
			description = [NSString stringWithFormat:@"%f", result];
		}
			break;
			
		case _C_BFLD:     // 'b'
		{
			NSUInteger result;
			
			NSUInteger (*DAL_NSUInteger_object_getIvar)(id, Ivar) = (NSUInteger (*)(id, Ivar))object_getIvar;
			result = DAL_NSUInteger_object_getIvar(instance, anIvar);
			
			description = DALBinaryRepresentationOfNSUInteger(result);
		}
			break;
			
		case _C_BOOL:     // 'B'
		{
			BOOL result = NO;
			
			BOOL (*DAL_BOOL_object_getIvar)(id, Ivar) = (BOOL (*)(id, Ivar))object_getIvar;
			result = DAL_BOOL_object_getIvar(instance, anIvar);
			
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
					if ([returnType isEqualToString:@"^{__CFArray=}"])
					{
						CFArrayRef result = NULL;
						
						CFArrayRef (*DAL_CFArrayRef_object_getIvar)(id, Ivar) = (CFArrayRef (*)(id, Ivar))object_getIvar;
						result = DAL_CFArrayRef_object_getIvar(instance, anIvar);
						
						NSArray *array = (__bridge NSArray *)(result);
						description = DALDescriptionOfFoundationObject(array);
					}
					else if ([returnType isEqualToString:@"^{__CFDictionary=}"])
					{
						CFDictionaryRef result = NULL;
						
						CFDictionaryRef (*DAL_CFDictionaryRef_object_getIvar)(id, Ivar) = (CFDictionaryRef (*)(id, Ivar))object_getIvar;
						result = DAL_CFDictionaryRef_object_getIvar(instance, anIvar);
						
						NSDictionary *dictionary = (__bridge NSDictionary *)(result);
						description = DALDescriptionOfFoundationObject(dictionary);
					}
					else if ([returnType isEqualToString:@"^{_NSZone=}"])
					{
						description = DALDescriptionForUnsupportedType(returnTypeChar);
					}
					else if ([returnType isEqualToString:@"^{CGColor=}"])
					{
						CGColorRef result = NULL;
						
						CGColorRef (*DAL_CGColorRef_object_getIvar)(id, Ivar) = (CGColorRef (*)(id, Ivar))object_getIvar;
						result = DAL_CGColorRef_object_getIvar(instance, anIvar);
						
						UIColor *color = [UIColor colorWithCGColor:result];
						description = DALDescriptionOfFoundationObject(color);
					}
					else if ([returnType isEqualToString:@"^{CGPath=}"])
					{
						CGPathRef result = NULL;
						
						CGPathRef (*DAL_CGPathRef_object_getIvar)(id, Ivar) = (CGPathRef (*)(id, Ivar))object_getIvar;
						result = DAL_CGPathRef_object_getIvar(instance, anIvar);
						
						if (result)
						{
							UIBezierPath *bezierPath = [UIBezierPath bezierPathWithCGPath:result];
							description = DALDescriptionOfFoundationObject(bezierPath);
						}
					}
					else
					{
						description = DALDescriptionForUnsupportedType(returnTypeChar);
					}
				}
					break;
					
				case 'v':
				{
					void *result;
					
					void *(*DAL_void_star_object_getIvar)(id, Ivar) = (void *(*)(id, Ivar))object_getIvar;
					result = DAL_void_star_object_getIvar(instance, anIvar);
					
					description = [NSString stringWithFormat:@"%p", result];
				}
					break;
					
				default:
					description = DALDescriptionForUnsupportedType(returnTypeChar);
					break;
			}
		}
			break;
			
		case _C_CHARPTR:  // '*'
		{
			char *result;
			
			char *(*DAL_char_star_object_getIvar)(id, Ivar) = (char *(*)(id, Ivar))object_getIvar;
			result = DAL_char_star_object_getIvar(instance, anIvar);
			
			description = [NSString stringWithUTF8String:result];
		}
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
			if ([typeString hasPrefix:@"{CGPoint="])
			{
				CGPoint result = CGPointZero;
				
				// TODO: Fix this
				CGPoint (*DAL_CGPoint_object_getIvar)(id, Ivar) = (CGPoint (*)(id, Ivar))object_getIvar;
				result = DAL_CGPoint_object_getIvar(instance, anIvar);
				
				description = NSStringFromCGPoint(result);
			}
			else if ([typeString hasPrefix:@"{CGSize="])
			{
				CGSize result = CGSizeZero;
				
				// TODO: Fix this
				CGSize (*DAL_CGSize_object_getIvar)(id, Ivar) = (CGSize (*)(id, Ivar))object_getIvar;
				result = DAL_CGSize_object_getIvar(instance, anIvar);
				
				description = NSStringFromCGSize(result);
			}
			else if ([typeString hasPrefix:@"{CGRect="])
			{
				CGRect result = CGRectZero;
				
				// TODO: Fix this
//				CGRect (*DAL_CGRect_object_getIvar)(id, Ivar) = (CGRect (*)(id, Ivar))object_getIvar;
//				result = DAL_CGRect_object_getIvar(instance, anIvar);
				
				description = NSStringFromCGRect(result);
			}
			else if ([typeString hasPrefix:@"{UIEdgeInsets="])
			{
				UIEdgeInsets result = UIEdgeInsetsZero;
				
				// TODO: Fix this
//				UIEdgeInsets (*DAL_UIEdgeInsets_object_getIvar)(id, Ivar) = (UIEdgeInsets (*)(id, Ivar))object_getIvar;
//				result = DAL_UIEdgeInsets_object_getIvar(instance, anIvar);
				
				description = NSStringFromUIEdgeInsets(result);
			}
			else if ([typeString hasPrefix:@"{CGAffineTransform="])
			{
				CGAffineTransform result = CGAffineTransformIdentity;
				
				// TODO: Fix this
//				CGAffineTransform (*DAL_CGAffineTransform_object_getIvar)(id, Ivar) = (CGAffineTransform (*)(id, Ivar))object_getIvar;
//				result = DAL_CGAffineTransform_object_getIvar(instance, anIvar);
				
				description = NSStringFromCGAffineTransform(result);
			}
			else if ([typeString hasPrefix:@"{CATransform3D="])
			{
				CATransform3D result = CATransform3DIdentity;
				
				// TODO: Fix this
//				CATransform3D (*DAL_CATransform3D_object_getIvar)(id, Ivar) = (CATransform3D (*)(id, Ivar))object_getIvar;
//				result = DAL_CATransform3D_object_getIvar(instance, anIvar);
				
				description = DALDescriptionOfCATransform3D(result);
			}
			else
			{
				// TODO: Implement creating description for struct
				/* UIView._viewFlags =
				 {?="userInteractionDisabled"b1"implementsDrawRect"b1"implementsDidScroll"b1"implementsMouseTracking"b1"hasBackgroundColor"b1"isOpaque"b1"becomeFirstResponderWhenCapable"b1"interceptMouseEvent"b1"deallocating"b1"debugFlash"b1"debugSkippedSetNeedsDisplay"b1"debugScheduledDisplayIsRequired"b1"isInAWindow"b1"isAncestorOfFirstResponder"b1"dontAutoresizeSubviews"b1"autoresizeMask"b6"patternBackground"b1"fixedBackgroundPattern"b1"dontAnimate"b1"superLayerIsView"b1"layerKitPatternDrawing"b1"multipleTouchEnabled"b1"exclusiveTouch"b1"hasViewController"b1"needsDidAppearOrDisappear"b1"gesturesEnabled"b1"deliversTouchesForGesturesToSuperview"b1"chargeEnabled"b1"skipsSubviewEnumeration"b1"needsDisplayOnBoundsChange"b1"hasTiledLayer"b1"hasLargeContent"b1"unused"b1"traversalMark"b1"appearanceIsInvalid"b1"monitorsSubtree"b1"hostsAutolayoutEngine"b1"constraintsAreClean"b1"subviewLayoutConstraintsAreClean"b1"intrinsicContentSizeConstraintsAreClean"b1"potentiallyHasDanglyConstraints"b1"doesNotTranslateAutoresizingMaskIntoConstraints"b1"autolayoutIsClean"b1"subviewsAutolayoutIsClean"b1"layoutFlushingDisabled"b1"layingOutFromConstraints"b1"wantsAutolayout"b1"subviewWantsAutolayout"b1"isApplyingValuesFromEngine"b1"isInAutolayout"b1"isUpdatingAutoresizingConstraints"b1"isUpdatingConstraints"b1"stayHiddenAwaitingReuse"b1"stayHiddenAfterReuse"b1"skippedLayoutWhileHiddenForReuse"b1"hasMaskView"b1"hasVisualAltitude"b1"hasBackdropMaskViews"b1"backdropMaskViewFlags"b3"delaysTouchesForSystemGestures"b1"subclassShouldDelayTouchForSystemGestures"b1"hasMotionEffects"b1"backdropOverlayMode"b2"tintAdjustmentMode"b2"isReferenceView"b1"focusState"b2"hasUserInterfaceIdiom"b1"userInterfaceIdiom"b3"ancestorDefinesTintColor"b1"ancestorDefinesTintAdjustmentMode"b1}
				 */
				
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
			const char *result;
			
			const char *(*DAL_const_char_star_object_getIvar)(id, Ivar) = (const char *(*)(id, Ivar))object_getIvar;
			result = DAL_const_char_star_object_getIvar(instance, anIvar);
			
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
			description = [NSString stringWithFormat:@"Object at memory address '%p' doesn't conform to NSObject protocol.", instance];
		}
	}
	else
	{
		description = @"(nil)";
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
		description = @"(nil)";
	}
	
	return description;
}

NSString *DALDescriptionForUnsupportedType(const char *type)
{
	return [NSString stringWithFormat:@"(description not yet implemented for: %@)", @(type)];
}

NSString *DALDescriptionOfCATransform3D(CATransform3D transform3D)
{
	NSMutableString *description = [NSMutableString string];
	
	[description appendFormat:@"{\t%f, ", transform3D.m11];
	[description appendFormat:@"%f, ", transform3D.m12];
	[description appendFormat:@"%f, ", transform3D.m13];
	[description appendFormat:@"%f, \n", transform3D.m14];
	[description appendFormat:@"\t%f, ", transform3D.m21];
	[description appendFormat:@"%f, ", transform3D.m22];
	[description appendFormat:@"%f, ", transform3D.m23];
	[description appendFormat:@"%f, \n", transform3D.m24];
	[description appendFormat:@"\t%f, ", transform3D.m31];
	[description appendFormat:@"%f, ", transform3D.m32];
	[description appendFormat:@"%f, ", transform3D.m33];
	[description appendFormat:@"%f, \n", transform3D.m34];
	[description appendFormat:@"\t%f, ", transform3D.m41];
	[description appendFormat:@"%f, ", transform3D.m42];
	[description appendFormat:@"%f, ", transform3D.m43];
	[description appendFormat:@"%f }", transform3D.m44];

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


#pragma mark -
#pragma mark - Convenience
id KeyWindowDescription(void)
{
	return [[[UIApplication sharedApplication] keyWindow] recursiveDescription];
}


#pragma mark -
#pragma mark - Swizzled Method Logging

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
		
		char *types = DALCopyTypesForMethod(aMethod);
		
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

#pragma mark Convenience

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
	
	void *(*DAL_void_star_objc_msgSend)(id, SEL, ...) = (void *(*)(id, SEL, ...))objc_msgSend;
	
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
				value = DAL_void_star_objc_msgSend(blockSelf, swizzledSelector);
				return value;
			} copy];
			break;
			
		case 1:
			block = [^void *(id __strong blockSelf, void *arg) {
				
				NSLog(@"<%@: %p> SEL: %@", NSStringFromClass([blockSelf class]), blockSelf, NSStringFromSelector(originalSelector));
				DALRetainAutorelease(blockSelf);
				
				void *value;
				value = DAL_void_star_objc_msgSend(blockSelf, swizzledSelector, arg);
				return value;
			} copy];
			break;
			
		case 2:
			block = [^void *(id __strong blockSelf, void *arg1, void *arg2) {
				
				NSLog(@"<%@: %p> SEL: %@", NSStringFromClass([blockSelf class]), blockSelf, NSStringFromSelector(originalSelector));
				DALRetainAutorelease(blockSelf);
				
				void *value;
				value = DAL_void_star_objc_msgSend(blockSelf, swizzledSelector, arg1, arg2);
				return value;
			} copy];
			break;
			
		case 3:
			block = [^void *(id __strong blockSelf, void *arg1, void *arg2, void *arg3) {
				
				NSLog(@"<%@: %p> SEL: %@", NSStringFromClass([blockSelf class]), blockSelf, NSStringFromSelector(originalSelector));
				DALRetainAutorelease(blockSelf);
				
				void *value;
				value = DAL_void_star_objc_msgSend(blockSelf, swizzledSelector, arg1, arg2, arg3);
				return value;
			} copy];
			break;
			
		case 4:
			block = [^void *(id __strong blockSelf, void *arg1, void *arg2, void *arg3, void *arg4) {
				
				NSLog(@"<%@: %p> SEL: %@", NSStringFromClass([blockSelf class]), blockSelf, NSStringFromSelector(originalSelector));
				DALRetainAutorelease(blockSelf);
				
				void *value;
				value = DAL_void_star_objc_msgSend(blockSelf, swizzledSelector, arg1, arg2, arg3, arg4);
				return value;
			} copy];
			break;
			
		case 5:
			block = [^void *(id __strong blockSelf, void *arg1, void *arg2, void *arg3, void *arg4, void *arg5) {
				
				NSLog(@"<%@: %p> SEL: %@", NSStringFromClass([blockSelf class]), blockSelf, NSStringFromSelector(originalSelector));
				DALRetainAutorelease(blockSelf);
				
				void *value;
				value = DAL_void_star_objc_msgSend(blockSelf, swizzledSelector, arg1, arg2, arg3, arg4, arg5);
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

void DALRetainAutorelease(id instance)
{
	SEL retainSelector = ({
		SEL sel = NULL;
		
		NSString *string = @"retain";
		SEL swizzledSel = NSSelectorFromString([DALSwizzledPrefix stringByAppendingString:string]);
		if ([instance respondsToSelector:swizzledSel])
		{
			sel = swizzledSel;
		}
		else
		{
			sel = NSSelectorFromString(string);
		}
		
		sel;
	});
	
	SEL autoreleaseSelector = ({
		SEL sel = NULL;
		
		NSString *string = @"autorelease";
		SEL swizzledSel = NSSelectorFromString([DALSwizzledPrefix stringByAppendingString:string]);
		if ([instance respondsToSelector:swizzledSel])
		{
			sel = swizzledSel;
		}
		else
		{
			sel = NSSelectorFromString(string);
		}
		
		sel;
	});
	
	objc_msgSend(objc_msgSend(instance, retainSelector), autoreleaseSelector);
}

char *DALCopyTypesForMethod(Method aMethod)
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

#endif
