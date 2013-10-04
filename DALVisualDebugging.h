//
//  DALDebugging
//  DALVisualDebugging.h
//
//  Created by Daniel Leber, 2013.
//

#if DEBUG

@interface UIWindow (DALVisualDebugging)

- (void)enableSlowAnimations;
- (void)disableSlowAnimations;

@end

#endif
