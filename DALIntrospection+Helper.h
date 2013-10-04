//
//  DALDebugging
//  DALIntrospection+Helper.h
//
//  Created by Daniel Leber, 2013.
//

#if DEBUG

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#pragma mark Introspection helpers
NSString *DALDescriptionOfProtocolsForClass(Class aClass);
NSString *DALDescriptionOfReturnOrParameterType(const char *type);
NSString *DALDescriptionOfPropertyAttributeType(objc_property_attribute_t attribute);
NSString *DALDescriptionOfReturnValueForIvar(id instance, Ivar anIvar);
SEL DALSelectorForPropertyOfClass(objc_property_t property, Class aClass);
const char *DALNewTypesForMethod(Method aMethod);

#pragma mark -fno-objc-arc
NSString *DALDescriptionOfReturnValueFromMethod(id instance, Method aMethod); // Will ignore Methods that take parameters
NSString *DALDescriptionForUnsupportedType(const char *type);
NSString *DALDescriptionOfFoundationObject(id object);
NSString *DALDescriptionOfCoreFoundationObject(void *object);
NSString *DALDescriptionOfReturnValueForIvar(id instance, Ivar anIvar);
BOOL DALShouldIgnoreMethod(Method aMethod);
BOOL DALShouldIgnoreSelector(SEL selector);
void *DALPerformSelector(id instance, SEL aSelector);
void DALInvokeMethodForResult(id instance, Method aMethod, void *result);
void DALRetainAutorelease(id instance);


#pragma mark - Swizzling Introspection helpers
id DALImplementationBlockForMethod(Method aMethod, SEL swizzledSelector, SEL originalSelector);
id DALBlockWithVoidReturnAndNumberOfArguments(unsigned numberOfArguments, SEL swizzledSelector, SEL originalSelector);
id DALBlockWithStructReturnAndNumberOfArguments(unsigned numberOfArguments, SEL swizzledSelector, SEL originalSelector);
id DALBlockWithIdReturnAndNumberOfArguments(unsigned numberOfArguments, SEL swizzledSelector, SEL originalSelector);

extern NSString * const DALSwizzledPrefix;

#endif
