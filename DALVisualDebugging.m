//
//  DALDebugging
//  DALVisualDebugging.m
//
//  Created by Daniel Leber, 2013.
//

#if DEBUG

@implementation UIWindow (DALVisualDebugging)

- (void)enableSlowAnimations;
{
	[[[[UIApplication sharedApplication] keyWindow] layer] setSpeed:0.1];
}

- (void)disableSlowAnimations;
{
	[[[[UIApplication sharedApplication] keyWindow] layer] setSpeed:1.0];
}

@end

#endif
