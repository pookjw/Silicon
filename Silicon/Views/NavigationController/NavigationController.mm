//
//  NavigationController.mm
//  Silicon
//
//  Created by Jinwoo Kim on 8/31/23.
//

#import "NavigationController.hpp"
#import "NavigationContentView.hpp"
#import <objc/message.h>

namespace _NavigationController {
namespace identifiers {
static NSToolbarIdentifier const toolbarIdentifier = @"_NavigationController.toolbar";
static NSToolbarItemIdentifier const backButtonItemIdentifier = @"NavigationController.backButtonItem";
}
}

@interface NavigationController () <NSToolbarDelegate> {
    NSMutableArray<NSViewController *> *_viewControllers;
}
@end

@implementation NavigationController

- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self NavigationController_commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self NavigationController_commonInit];
    }
    
    return self;
}

- (void)dealloc {
    static_cast<NavigationContentView *>(self.view).didChangeToolbarHandler = std::nullopt;
    [_viewControllers release];
    [super dealloc];
}

- (void)NavigationController_commonInit {
    _viewControllers = [NSMutableArray<NSViewController *> new];
}

- (void)loadView {
    __block decltype(self) unretainedSelf = self;
    NavigationContentView *view = [[NavigationContentView alloc] initWithDidChangeToolbarHandler:^(NSToolbar * _Nullable toolbar) {
        [unretainedSelf didChangeToolbar:toolbar];
    }];
    
    self.view = view;
    [view release];
}

- (void)pushViewController:(NSViewController *)viewController transitionOptions:(NSViewControllerTransitionOptions)options completionHandler:(void (^)(void))completionHandler {
    viewController.view.translatesAutoresizingMaskIntoConstraints = YES;
    viewController.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    viewController.view.frame = self.view.bounds;
    [self.view addSubview:viewController.view];
    [self addChildViewController:viewController];
    
    if (_viewControllers.count) {
        NSViewController *previousViewController = _viewControllers.lastObject;
        [_viewControllers addObject:viewController];
        [self reloadToolbar];
        
        [self transitionFromViewController:previousViewController
                          toViewController:viewController
                                   options:options
                         completionHandler:^{
            [previousViewController.view removeFromSuperview];
            if (completionHandler) {
                completionHandler();
            }
        }];
    } else {
        [_viewControllers addObject:viewController];
        [self reloadToolbar];
        if (completionHandler) {
            completionHandler();
        }
    }
}

- (void)pushViewController:(NSViewController *)viewController completionHandler:(void (^)())completionHandler {
    [self pushViewController:viewController transitionOptions:NSViewControllerTransitionCrossfade | NSViewControllerTransitionSlideForward completionHandler:completionHandler];
}

- (NSViewController *)popViewControllerWithTransitionOptions:(NSViewControllerTransitionOptions)options completionHandler:(void (^ _Nullable)(void))completionHandler {
    NSUInteger count = _viewControllers.count;
    
    if (count == 0) {
        if (completionHandler) {
            completionHandler();
        }
        return nullptr;
    } else if (count == 1) {
        NSViewController *lastViewController = _viewControllers.lastObject;
        [_viewControllers removeObject:lastViewController];
        [self reloadToolbar];
        [lastViewController.view removeFromSuperview];
        [lastViewController removeFromParentViewController];
        if (completionHandler) {
            completionHandler();
        }
        
        return lastViewController;
    } else {
        NSViewController *fromViewController = _viewControllers.lastObject;
        NSViewController *toViewController = _viewControllers[count - 2];
        
        [_viewControllers removeObject:fromViewController];
        [self reloadToolbar];
        toViewController.view.translatesAutoresizingMaskIntoConstraints = YES;
        toViewController.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        toViewController.view.frame = self.view.bounds;
        [self.view addSubview:toViewController.view];
        
        [self transitionFromViewController:fromViewController
                          toViewController:toViewController
                                   options:options
                         completionHandler:^{
            [fromViewController.view removeFromSuperview];
            [fromViewController removeFromParentViewController];
            if (completionHandler) {
                completionHandler();
            }
        }];
        
        return nullptr;
    }
}

- (NSViewController *)popViewControllerWithCompletionHandler:(void (^)())completionHandler {
    return [self popViewControllerWithTransitionOptions:NSViewControllerTransitionCrossfade | NSViewControllerTransitionSlideBackward completionHandler:nullptr];
}

- (NSArray<NSViewController *> *)viewControllers {
    return [[_viewControllers retain] autorelease];
}

- (void)setViewControllers:(NSArray<NSViewController *> *)viewControllers {
    [self setViewControllers:viewControllers completionHandler:nullptr];
}

- (void)setViewControllers:(NSArray<NSViewController *> *)viewControllers transitionOptions:(NSViewControllerTransitionOptions)options completionHandler:(void (^ _Nullable)(void))completionHandler {
    NSViewController * _Nullable previousLastViewController = _viewControllers.lastObject;
    NSViewController * _Nullable nextLastViewController = viewControllers.lastObject;
    
    [_viewControllers release];
    _viewControllers = [viewControllers mutableCopy];
    [self reloadToolbar];
    
    if ((previousLastViewController == nullptr) && (nextLastViewController == nullptr)) {
        if (completionHandler) {
            completionHandler();
        }
    } else if ((previousLastViewController != nullptr) && (nextLastViewController == nullptr)) {
        [previousLastViewController.view removeFromSuperview];
        [previousLastViewController removeFromParentViewController];
        if (completionHandler) {
            completionHandler();
        }
    } else if ((previousLastViewController == nullptr) && (nextLastViewController != nullptr)) {
        nextLastViewController.view.translatesAutoresizingMaskIntoConstraints = YES;
        nextLastViewController.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        nextLastViewController.view.frame = self.view.bounds;
        [self.view addSubview:nextLastViewController.view];
        [self addChildViewController:nextLastViewController];
        
        if (completionHandler) {
            completionHandler();
        }
    } else if ([previousLastViewController isEqual:nextLastViewController]) {
        if (completionHandler) {
            completionHandler();
        }
    } else {
        nextLastViewController.view.translatesAutoresizingMaskIntoConstraints = YES;
        nextLastViewController.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        nextLastViewController.view.frame = self.view.bounds;
        [self.view addSubview:nextLastViewController.view];
        [self addChildViewController:nextLastViewController];
        
        [self transitionFromViewController:previousLastViewController
                          toViewController:nextLastViewController
                                   options:options
                         completionHandler:^{
            [previousLastViewController.view removeFromSuperview];
            [previousLastViewController removeFromParentViewController];
            if (completionHandler) {
                completionHandler();
            }
        }];
    }
}

- (void)setViewControllers:(NSArray<NSViewController *> *)viewControllers completionHandler:(void (^)())completionHandler {
    [self setViewControllers:viewControllers transitionOptions:NSViewControllerTransitionCrossfade | NSViewControllerTransitionSlideForward completionHandler:completionHandler];
}

- (void)reloadToolbar {
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:_NavigationController::identifiers::toolbarIdentifier];
    toolbar.displayMode = NSToolbarDisplayModeIconOnly;
    toolbar.delegate = self;
    
    self.view.window.toolbar = toolbar;
    [toolbar release];
}

- (void)didChangeToolbar:(NSToolbar * _Nullable)toolbar {
    if (!toolbar) {
        [self reloadToolbar];
    }
}

- (void)didTriggerBackButtonItem:(NSToolbarItem *)sender {
    [self popViewControllerWithCompletionHandler:nullptr];
}

#pragma mark - NSToolbarDelegate

- (NSArray<NSToolbarItemIdentifier> *)toolbarNavigationalItemIdentifiers:(NSToolbar *)toolbar {
    return @[_NavigationController::identifiers::backButtonItemIdentifier];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    NSViewController * _Nullable lastViewController = _viewControllers.lastObject;
    NSArray<NSToolbarItemIdentifier> *itemIdentifiers = @[
        _NavigationController::identifiers::backButtonItemIdentifier
    ];
    
    if ([lastViewController respondsToSelector:@selector(toolbarAllowedItemIdentifiers:)]) {
        NSArray<NSToolbarItemIdentifier> *results = [static_cast<id<NSToolbarDelegate>>(lastViewController) toolbarAllowedItemIdentifiers:toolbar];
        
        if (_viewControllers.count == 1) {
            return results;
        } else {
            return [itemIdentifiers arrayByAddingObjectsFromArray:results];
        }
    } else {
        return itemIdentifiers;
    }
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    NSViewController * _Nullable lastViewController = _viewControllers.lastObject;
    NSArray<NSToolbarItemIdentifier> *itemIdentifiers = @[
        _NavigationController::identifiers::backButtonItemIdentifier
    ];
    
    if ([lastViewController respondsToSelector:@selector(toolbarDefaultItemIdentifiers:)]) {
        NSArray<NSToolbarItemIdentifier> *results = [static_cast<id<NSToolbarDelegate>>(lastViewController) toolbarDefaultItemIdentifiers:toolbar];
        
        if (_viewControllers.count == 1) {
            return results;
        } else {
            return [itemIdentifiers arrayByAddingObjectsFromArray:results];
        }
    } else {
        return itemIdentifiers;
    }
}

- (NSSet<NSToolbarItemIdentifier> *)toolbarImmovableItemIdentifiers:(NSToolbar *)toolbar {
    NSViewController * _Nullable lastViewController = _viewControllers.lastObject;
    NSSet<NSToolbarItemIdentifier> *itemIdentifiers = [NSSet<NSToolbarItemIdentifier> setWithArray:@[
        _NavigationController::identifiers::backButtonItemIdentifier
    ]];
    
    if ([lastViewController respondsToSelector:@selector(toolbarImmovableItemIdentifiers:)]) {
        NSSet<NSToolbarItemIdentifier> *results = [static_cast<id<NSToolbarDelegate>>(lastViewController) toolbarImmovableItemIdentifiers:toolbar];
        
        if (_viewControllers.count == 1) {
            return results;
        } else {
            return [itemIdentifiers setByAddingObjectsFromSet:results];
        }
    } else {
        return itemIdentifiers;
    }
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar {
    NSViewController * _Nullable lastViewController = _viewControllers.lastObject;
    NSArray<NSToolbarItemIdentifier> *itemIdentifiers = @[
        _NavigationController::identifiers::backButtonItemIdentifier
    ];
    
    if ([lastViewController respondsToSelector:@selector(toolbarSelectableItemIdentifiers:)]) {
        NSArray<NSToolbarItemIdentifier> *results = [static_cast<id<NSToolbarDelegate>>(lastViewController) toolbarSelectableItemIdentifiers:toolbar];
        
        if (_viewControllers.count == 1) {
            return results;
        } else {
            return [itemIdentifiers arrayByAddingObjectsFromArray:results];
        }
    } else {
        return itemIdentifiers;
    }
}

- (BOOL)toolbar:(NSToolbar *)toolbar itemIdentifier:(NSToolbarItemIdentifier)itemIdentifier canBeInsertedAtIndex:(NSInteger)index {
    if ([itemIdentifier isEqualToString:_NavigationController::identifiers::backButtonItemIdentifier]) {
        return YES;
    } else {
        NSViewController * _Nullable lastViewController = _viewControllers.lastObject;
        if ([lastViewController respondsToSelector:@selector(toolbar:itemIdentifier:canBeInsertedAtIndex:)]) {
            return [static_cast<id<NSToolbarDelegate>>(lastViewController) toolbar:toolbar itemIdentifier:itemIdentifier canBeInsertedAtIndex:index];
        } else {
            return YES;
        }
    }
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSToolbarItemIdentifier)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    if ([itemIdentifier isEqualToString:_NavigationController::identifiers::backButtonItemIdentifier]) {
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        item.image = [NSImage imageWithSystemSymbolName:@"chevron.backward" accessibilityDescription:nullptr];
        item.target = self;
        item.action = @selector(didTriggerBackButtonItem:);
        
        return [item autorelease];
    } else {
        NSViewController * _Nullable lastViewController = _viewControllers.lastObject;
        if ([lastViewController respondsToSelector:@selector(toolbar:itemForItemIdentifier:willBeInsertedIntoToolbar:)]) {
            return [static_cast<id<NSToolbarDelegate>>(lastViewController) toolbar:toolbar itemForItemIdentifier:itemIdentifier willBeInsertedIntoToolbar:flag];
        } else {
            return nullptr;
        }
    }
}

- (void)toolbarWillAddItem:(NSNotification *)notification {
    NSViewController * _Nullable lastViewController = _viewControllers.lastObject;
    if ([lastViewController respondsToSelector:@selector(toolbarWillAddItem:)]) {
        [static_cast<id<NSToolbarDelegate>>(lastViewController) toolbarWillAddItem:notification];
    }
}

- (void)toolbarDidRemoveItem:(NSNotification *)notification {
    NSViewController * _Nullable lastViewController = _viewControllers.lastObject;
    if ([lastViewController respondsToSelector:@selector(toolbarDidRemoveItem:)]) {
        [static_cast<id<NSToolbarDelegate>>(lastViewController) toolbarDidRemoveItem:notification];
    }
}

@end
