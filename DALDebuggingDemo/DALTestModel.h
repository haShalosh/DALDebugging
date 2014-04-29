//
//  DALTestModel.h
//  DALDebugging
//
//  Created by Daniel Leber on 4/27/14.
//  Copyright (c) 2014 Daniel Leber. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
	unsigned int first:1;
	unsigned int second:1;
	unsigned int third:1;
	unsigned int fourth:1;
} DALStruct;


@interface DALTestModel : NSObject

@property (nonatomic, strong) NSObject *anObject;
@property (nonatomic, strong) Class aClass;
@property (nonatomic) SEL aSelector;
@property (nonatomic) char aChar;
@property (nonatomic) unsigned char anUnsignedChar;
@property (nonatomic) short aShort;
@property (nonatomic) unsigned short anUnsignedShort;
@property (nonatomic) int anInt;
@property (nonatomic) unsigned int anUnsignedInt;
@property (nonatomic) long aLong;
@property (nonatomic) unsigned long anUnsignedLong;
@property (nonatomic) long long aLongLong;
@property (nonatomic) unsigned long long anUnsignedLongLong;
@property (nonatomic) float aFloat;
@property (nonatomic) double aDouble;
//@property (nonatomic) BFLD;
@property (nonatomic) BOOL aBool;
//@property (nonatomic) VOID;
//@property (nonatomic) UNDEF;
@property (nonatomic) CFArrayRef anArrayRef;
@property (nonatomic) CGColorRef aColorRef;
@property (nonatomic) CFDictionaryRef aDictionaryRef;
@property (nonatomic) CGPathRef aPathRef;
@property (nonatomic) char *aCharStar;
//@property (nonatomic) ATOM;
//@property (nonatomic) ARY_B;
//@property (nonatomic) ARY_E;
//@property (nonatomic) UNION_B;
//@property (nonatomic) UNION_E;
@property (nonatomic) CGPoint aPoint;
@property (nonatomic) CGSize aSize;
@property (nonatomic) CGRect aRect;
@property (nonatomic) UIEdgeInsets anEdgeInsets;
@property (nonatomic) CGAffineTransform anAffineTransform;
@property (nonatomic) CATransform3D aTransform3D;
@property (nonatomic) DALStruct aStruct;
//@property (nonatomic) STRUCT_E;
//@property (nonatomic) VECTOR;
@property (nonatomic) const char *aConstCharStar;

- (void)doFoo:(id)arg1 withBar:(id)arg2;
- (dispatch_block_t)returnBlock;

@end
