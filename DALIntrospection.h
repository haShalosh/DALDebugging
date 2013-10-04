//
//  DALDebugging
//  DALIntrospection.h
//
//  Created by Daniel Leber, 2013.
//

#if DEBUG

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#pragma mark - Class Introspection
NSString *DALClassAncestryWithProtocolsDescription(Class aClass, BOOL withProtocols);

NSString *DALClassIvarsDescription(Class aClass);
NSString *DALClassMethodsDescription(Class aClass);
NSString *DALClassPropertiesDescription(Class aClass);

#pragma mark Instance Introspection
NSString *DALInstanceIvarsDescription(id instance);
NSString *DALInstanceMethodsDescription(id instance);
NSString *DALInstancePropertiesDescription(id instance);

#pragma mark Protocol Introspection
NSString *DALProtocolDescription(Protocol *aProtocol); // Not yet implemented...


#pragma mark - Convenience
/// \brief This is equivalent to calling [[[UIApplication sharedApplication] keyWindow] recursiveDescription];
NSString *KeyWindowDescription();


#pragma mark - Swizzling Introspection
/// \brief This will swizzle all instance methods for the specifiec class. Note: This is a work-in-progress and _will_ crash your app!
void DALSwizzleInstanceMethodsForClass(Class aClass);

#endif
