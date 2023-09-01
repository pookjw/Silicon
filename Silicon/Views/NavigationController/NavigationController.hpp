//
//  NavigationController.h
//  Silicon
//
//  Created by Jinwoo Kim on 8/31/23.
//

#import <Cocoa/Cocoa.h>
#import <cinttypes>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface NavigationController : NSViewController
@property (class, readonly, nonatomic) std::uint8_t *navigationItemAssociationKey;
@property (nonatomic, copy) NSArray<NSViewController *> *viewControllers;
@property (nonatomic, assign) BOOL overrideToolbar;

- (void)pushViewController:(NSViewController *)viewController transitionOptions:(NSViewControllerTransitionOptions)options completionHandler:(void (^ _Nullable)(void))completionHandler;
- (void)pushViewController:(NSViewController *)viewController completionHandler:(void (^ _Nullable)(void))completionHandler;

- (NSViewController * _Nullable)popViewControllerWithTransitionOptions:(NSViewControllerTransitionOptions)options completionHandler:(void (^ _Nullable)(void))completionHandler;
- (NSViewController * _Nullable)popViewControllerWithCompletionHandler:(void (^ _Nullable)(void))completionHandler;

- (void)setViewControllers:(NSArray<NSViewController *> *)viewControllers transitionOptions:(NSViewControllerTransitionOptions)options completionHandler:(void (^ _Nullable)(void))completionHandler;
- (void)setViewControllers:(NSArray<NSViewController *> *)viewControllers completionHandler:(void (^ _Nullable)(void))completionHandler;
@end

NS_HEADER_AUDIT_END(nullability, sendability)
