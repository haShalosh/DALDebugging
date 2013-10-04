//
//  DALDebugging
//  NSObject+DALIntrospection.h
//
//  Created by Daniel Leber, 2013.
//

#if DEBUG

#import <Foundation/Foundation.h>

@interface NSObject (DALIntrospection)

#pragma mark - Class
+ (NSString *)ancestryDescription;
+ (NSString *)ancestryWithProtocolsDescription;
+ (NSString *)ivarsDescription;
+ (NSString *)methodsDescription;
+ (NSString *)propertiesDescription;

#pragma mark - Instance
- (NSString *)ancestryDescription;
- (NSString *)ancestryWithProtocolsDescription;
- (NSString *)ivarsDescription;
- (NSString *)methodsDescription;
- (NSString *)propertiesDescription;

@end

#endif
