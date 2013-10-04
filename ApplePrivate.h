//
//  DALDebugging
//  ApplePrivate.h
//
//  Created by Daniel Leber, 2013.
//

#if DEBUG

#import <UIKit/UIKit.h>

#if __IPHONE_7_0

@interface NSObject (ApplePrivate_iOS7)

/// \return A description of all the ivars in the class and it's superclasses.
- (id)_ivarDescription NS_AVAILABLE_IOS(7_0);

/// \return A description of all the methods on the class and it's superclasses.
- (id)_methodDescription NS_AVAILABLE_IOS(7_0);

/// \return A description of all the methods on the class and it's superclasses, excluding Apple classes.
- (id)_shortMethodDescription NS_AVAILABLE_IOS(7_0);

- (id)__ivarDescriptionForClass:(Class)arg1;
- (id)__methodDescriptionForClass:(Class)arg1;

@end

#endif

#pragma mark -
@interface UINib (DALApplePrivate)

/// \brief The bundle resource name is accessible by -[self->storage bundleResourceName].
/// \return The bundle used to initialize the nib.
- (id)effectiveBundle;

/// \return The path to the nib on disk
- (id)bundleResourcePath;

@end

#pragma mark -
@interface UIResponder (ApplePrivate)

/// \return The next view controller going up the responder chain
- (id)_nextViewControllerInResponderChain;

@end

#pragma mark -
@interface UIView (ApplePrivate)

/// \return An array of the gesture recognizers.
- (id)_gestureRecognizers;

/// \brief Appears to be identical to -window.
/// \return An instance or subclass of UIView.
- (id)_rootView;

/// \return The first view controller going up the responder chain.
- (id)_viewControllerForAncestor;

/// \return A BOOL of whether the view, or one of it's ancestors, is hidden.
- (BOOL)isHiddenOrHasHiddenAncestor;

/// \return A text representation of the view hierarchy.
- (id)recursiveDescription;
@end

#pragma mark -
@interface UIViewController (ApplePrivate)

/// \return The NIB parameter used to initialize the view controller.
- (id)nibName;

/// \return The bundle parameter used to initialize the view controller.
- (id)nibBundle;

@end

#pragma mark -
@interface UIWindow (ApplePrivate)

/// \return A JSON compatible representation of the view hierarchy.
- (id)representation;

@end

#endif
