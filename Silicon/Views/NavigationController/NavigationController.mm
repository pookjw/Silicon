//
//  NavigationController.mm
//  Silicon
//
//  Created by Jinwoo Kim on 8/31/23.
//

#import "NavigationController.hpp"
#import "NavigationContentView.hpp"
#import "NavigationItem.hpp"
#import <objc/message.h>
#import <objc/runtime.h>
#import <memory>
#import <cinttypes>

namespace _NavigationController {
namespace identifiers {
static NSToolbarIdentifier const toolbarIdentifier = @"_NavigationController.toolbar";
static NSToolbarItemIdentifier const backButtonItemIdentifier = @"NavigationController.backButtonItem";
}

namespace keys {
std::uint8_t *navigationItemAssociationKey = nullptr;
}
}

@interface NavigationController () <NSToolbarDelegate, NSToolbarItemValidation> {
    NSMutableArray<NSViewController *> *_viewControllers;
}

@property (assign) std::shared_ptr<std::uint8_t> navigationalItemIdentifiersContext;
@property (assign) std::shared_ptr<std::uint8_t> itemIdentifiersContext;
@property (assign) std::shared_ptr<std::uint8_t> toolbarItemHandlerContext;
@property (assign, readonly, nonatomic) NavigationItem * _Nullable lastNavigationItem;
@end

@implementation NavigationController

+ (std::uint8_t *)navigationItemAssociationKey {
    if (!_NavigationController::keys::navigationItemAssociationKey) {
        _NavigationController::keys::navigationItemAssociationKey = new std::uint8_t;
    }
    
    return _NavigationController::keys::navigationItemAssociationKey;
}

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
    [self removeObserversFromLastNavigationItem];
    [_viewControllers release];
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == _navigationalItemIdentifiersContext.get()) {
        [self reloadToolbar];
    } else if (context == _itemIdentifiersContext.get()) {
        [self reloadToolbar];
    } else if (context == _toolbarItemHandlerContext.get()) {
        [self reloadToolbar];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)loadView {
    __block decltype(self) unretainedSelf = self;
    NavigationContentView *view = [[NavigationContentView alloc] initWithDidChangeToolbarHandler:^(NSToolbar * _Nullable toolbar) {
        [unretainedSelf didChangeToolbar:toolbar];
    }];
    
    self.view = view;
    [view release];
}

- (void)NavigationController_commonInit {
    _viewControllers = [NSMutableArray<NSViewController *> new];
    _overrideToolbar = YES;
    _navigationalItemIdentifiersContext = std::make_shared<std::uint8_t>();
    _itemIdentifiersContext = std::make_shared<std::uint8_t>();
    _toolbarItemHandlerContext = std::make_shared<std::uint8_t>();
}

- (void)pushViewController:(NSViewController *)viewController transitionOptions:(NSViewControllerTransitionOptions)options completionHandler:(void (^)(void))completionHandler {
    viewController.view.translatesAutoresizingMaskIntoConstraints = YES;
    viewController.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    viewController.view.frame = self.view.bounds;
    [self.view addSubview:viewController.view];
    [self addChildViewController:viewController];
    
    if (_viewControllers.count) {
        NSViewController *previousViewController = _viewControllers.lastObject;
        [self willChangeViewControllers];
        [_viewControllers addObject:viewController];
        [self didChangeViewControllers];
        
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
        [self willChangeViewControllers];
        [_viewControllers addObject:viewController];
        [self didChangeViewControllers];
        
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
        
        [self willChangeViewControllers];
        [_viewControllers removeObject:lastViewController];
        [self didChangeViewControllers];
        
        [lastViewController.view removeFromSuperview];
        [lastViewController removeFromParentViewController];
        if (completionHandler) {
            completionHandler();
        }
        
        return lastViewController;
    } else {
        NSViewController *fromViewController = _viewControllers.lastObject;
        NSViewController *toViewController = _viewControllers[count - 2];
        
        [self willChangeViewControllers];
        [_viewControllers removeObject:fromViewController];
        [self didChangeViewControllers];
        
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
    
    [self willChangeViewControllers];
    [_viewControllers release];
    _viewControllers = [viewControllers mutableCopy];
    [self didChangeViewControllers];
    
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

- (void)willChangeViewControllers {
    [self removeObserversFromLastNavigationItem];
}

- (void)didChangeViewControllers {
    [self reloadToolbar];
    [self addObserversFromLastNavigationItem];
}

- (void)removeObserversFromLastNavigationItem {
    [self.lastNavigationItem removeObserver:self forKeyPath:@"navigationalItemIdentifiers" context:_navigationalItemIdentifiersContext.get()];
    [self.lastNavigationItem removeObserver:self forKeyPath:@"itemIdentifiers" context:_itemIdentifiersContext.get()];
    [self.lastNavigationItem removeObserver:self forKeyPath:@"toolbarItemHandler" context:_toolbarItemHandlerContext.get()];
}

- (void)addObserversFromLastNavigationItem {
    [self.lastNavigationItem addObserver:self forKeyPath:@"navigationalItemIdentifiers" options:NSKeyValueObservingOptionNew context:_navigationalItemIdentifiersContext.get()];
    [self.lastNavigationItem addObserver:self forKeyPath:@"itemIdentifiers" options:NSKeyValueObservingOptionNew context:_itemIdentifiersContext.get()];
    [self.lastNavigationItem addObserver:self forKeyPath:@"toolbarItemHandler" options:NSKeyValueObservingOptionNew context:_toolbarItemHandlerContext.get()];
}

- (void)reloadToolbar {
    if (!self.overrideToolbar) return;
    
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:_NavigationController::identifiers::toolbarIdentifier];
    toolbar.displayMode = NSToolbarDisplayModeIconOnly;
    toolbar.delegate = self;
    
    self.view.window.toolbar = toolbar;
    [toolbar release];
}

- (void)didChangeToolbar:(NSToolbar * _Nullable)toolbar {
    if (![toolbar.identifier isEqualToString:_NavigationController::identifiers::toolbarIdentifier]) {
        [self reloadToolbar];
    }
}

- (void)didTriggerBackButtonItem:(NSToolbarItem *)sender {
    [self popViewControllerWithCompletionHandler:nullptr];
}

- (void)setOverrideToolbar:(BOOL)overrideToolbar {
    BOOL oldValue = _overrideToolbar;
    if (oldValue == overrideToolbar) return;
    
    _overrideToolbar = overrideToolbar;
    
    if (overrideToolbar) {
        [self reloadToolbar];
    } else {
        if ([self.view.window.toolbar.identifier isEqualToString:_NavigationController::identifiers::toolbarIdentifier]) {
            self.view.window.toolbar = nullptr;
        }
    }
}

- (NavigationItem *)lastNavigationItem {
    NSViewController * _Nullable lastViewController = _viewControllers.lastObject;
    
    if (!lastViewController) return nullptr;
    
    return objc_getAssociatedObject(lastViewController, NavigationController.navigationItemAssociationKey);
}

#pragma mark - NSToolbarDelegate

- (NSArray<NSToolbarItemIdentifier> *)toolbarNavigationalItemIdentifiers:(NSToolbar *)toolbar {
    return [@[_NavigationController::identifiers::backButtonItemIdentifier] arrayByAddingObjectsFromArray:self.lastNavigationItem.navigationalItemIdentifiers];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
    NavigationItem * _Nullable lastNavigationItem = self.lastNavigationItem;
    NSArray<NSToolbarIdentifier> * _Nullable allItemIdentifiers = [lastNavigationItem.navigationalItemIdentifiers arrayByAddingObjectsFromArray:lastNavigationItem.itemIdentifiers];
    
    if (_viewControllers.count < 2) {
        return allItemIdentifiers;
    } else {
        return [@[_NavigationController::identifiers::backButtonItemIdentifier] arrayByAddingObjectsFromArray:allItemIdentifiers];
    }
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
    return [self toolbarAllowedItemIdentifiers:toolbar];
}

- (NSSet<NSToolbarItemIdentifier> *)toolbarImmovableItemIdentifiers:(NSToolbar *)toolbar {
    return [NSSet setWithArray:[self toolbarAllowedItemIdentifiers:toolbar]];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSToolbarItemIdentifier)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
    if ([itemIdentifier isEqualToString:_NavigationController::identifiers::backButtonItemIdentifier]) {
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        item.image = [NSImage imageWithSystemSymbolName:@"chevron.backward" accessibilityDescription:nullptr];
        item.target = self;
        item.action = @selector(didTriggerBackButtonItem:);
        
        return [item autorelease];
    } else {
        NavigationItem * _Nullable lastNavigationItem = self.lastNavigationItem;
        return lastNavigationItem.toolbarItemHandler(itemIdentifier);
    }
}

@end
