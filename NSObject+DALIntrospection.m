//
//  DALDebugging
//  NSObject+DALIntrospection.m
//
//  Created by Daniel Leber, 2013.
//

#if DEBUG

#import "NSObject+DALIntrospection.h"
#import "DALIntrospection.h"

@implementation NSObject (DALIntrospection)

#pragma mark - Class

+ (NSString *)ancestryDescription
{
	return DALClassAncestryWithProtocolsDescription(self, NO);
}

+ (NSString *)ancestryWithProtocolsDescription
{
	return DALClassAncestryWithProtocolsDescription(self, YES);
}

+ (NSString *)ivarsDescription
{
	return DALClassIvarsDescription(self);
}

+ (NSString *)methodsDescription
{
	return DALClassMethodsDescription(self);
}

+ (NSString *)propertiesDescription
{
	return DALClassPropertiesDescription(self);
}

#pragma mark - Instance

- (NSString *)ancestryDescription
{
	return DALClassAncestryWithProtocolsDescription([self class], NO);
}

- (NSString *)ancestryWithProtocolsDescription
{
	return DALClassAncestryWithProtocolsDescription([self class], YES);
}

- (NSString *)ivarsDescription
{
	return DALInstanceIvarsDescription(self);
}

- (NSString *)methodsDescription
{
	return DALInstanceMethodsDescription(self);
}

- (NSString *)propertiesDescription
{
	return DALInstancePropertiesDescription(self);
}

@end

#endif
