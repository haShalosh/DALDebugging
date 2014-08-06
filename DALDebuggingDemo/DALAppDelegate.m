//
//  DALAppDelegate.m
//  DALDebuggingDemo
//
//  Created by Daniel Leber on 4/27/14.
//  Copyright (c) 2014 Daniel Leber. All rights reserved.
//

#import "DALAppDelegate.h"
#import "NSObject+DALDebugging.h"
#import "NSProxy+DALDebugging.h"
#import "DALTestModel.h"
#import "DALIntrospection.h"

@implementation DALAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Testing on custom object
//	DALTestModel *testModel = [[DALTestModel alloc] init];
//	testModel.anObject = application;
//	testModel.aClass = [application class];
//	testModel.aSelector = _cmd;
//	testModel.aChar = 10;
//	testModel.anUnsignedChar = 20;
//	testModel.aShort = 30;
//	testModel.anUnsignedShort = 40;
//	testModel.anInt = 50;
//	testModel.anUnsignedInt = 60;
//	testModel.aLong = 70;
//	testModel.anUnsignedLong = 80;
//	testModel.aLongLong = 90;
//	testModel.anUnsignedLongLong = 100;
//	testModel.aFloat = 111.111;
//	testModel.aDouble = 123.456;
//	testModel.aBool = YES;
//	testModel.anArrayRef = CFBridgingRetain(@[@"array"]);
//	testModel.aColorRef = [UIColor redColor].CGColor;
//	testModel.aDictionaryRef = CFBridgingRetain(@{@"key": @"value"});
//	testModel.aPathRef = CGPathCreateWithRect(CGRectMake(0, 0, 100, 100), NULL);
//	testModel.aCharStar = "char star";
//	testModel.aPoint = CGPointMake(100, 200);
//	testModel.aSize = CGSizeMake(200, 300);
//	testModel.aRect = CGRectMake(100, 200, 300, 400);
//	testModel.anEdgeInsets = UIEdgeInsetsMake(10, 20, 30, 40);
//	testModel.anAffineTransform = CGAffineTransformIdentity;
//	testModel.aTransform3D = CATransform3DIdentity;
//	testModel.aStruct = (DALStruct){1,0,1,0};
//	testModel.aConstCharStar = "const char star";
//	
//	NSString *ivarDescription = DAL_ivarDescription(testModel);
//	NSString *methodDescription = DAL_methodDescription(testModel);
//	NSString *shortMethodDescription = DAL_shortMethodDescription(testModel);
	
	// Testing on NSProxy
//	NSProxy *proxy = [NSProxy alloc];
//	NSString *proxyIvarDescription = [proxy _ivarDescription];
//	NSString *proxyMethodDescription = [proxy _methodDescription];
//	NSString *proxyShortMethodDescription = [proxy _shortMethodDescription];
	
	// Override point for customization after application launch.
	return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
