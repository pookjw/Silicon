//
//  TestNavigationViewController.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/1/23.
//

#import "TestNavigationViewController.hpp"
#import "NavigationController.hpp"
#import "NavigationItem.hpp"
#import <objc/runtime.h>

@interface TestNavigationViewController ()
@property (retain) NavigationItem *navigationItem;
@end

@implementation TestNavigationViewController

- (void)dealloc {
    [_navigationItem release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NavigationItem *navigationItem = [NavigationItem new];
    navigationItem.toolbarItemHandler = ^NSToolbarItem * _Nullable (NSToolbarItemIdentifier itemIdentifier) {
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        item.title = itemIdentifier;
        
        return [item autorelease];
    };
    
    objc_setAssociatedObject(self, NavigationController.navigationItemAssociationKey, navigationItem, OBJC_ASSOCIATION_RETAIN);
    self.navigationItem = navigationItem;
    [navigationItem release];
    
    NSStackView *stackView = [NSStackView new];
    stackView.distribution = NSStackViewDistributionFillProportionally;
    stackView.orientation = NSUserInterfaceLayoutOrientationVertical;
    stackView.alignment = NSLayoutAttributeCenterX;
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSButton *addNavigationItemButton = [NSButton buttonWithTitle:@"Add Navigation Item"
                                                           target:self
                                                           action:@selector(didTriggerAddNavigationItemButton:)];
    
    NSButton *removeNavigationItemButton = [NSButton buttonWithTitle:@"Remove Navigation Item"
                                                              target:self
                                                              action:@selector(didTriggerRemoveNavigationItemButton:)];
    
    NSButton *addItemButton = [NSButton buttonWithTitle:@"Add Item"
                                                 target:self
                                                 action:@selector(didTriggerAddItemButton:)];
    
    NSButton *removeItemButton = [NSButton buttonWithTitle:@"Remove Item"
                                                    target:self
                                                    action:@selector(didTriggerRemoveItemButton:)];
    
    [stackView addArrangedSubview:addNavigationItemButton];
    [stackView addArrangedSubview:removeNavigationItemButton];
    [stackView addArrangedSubview:addItemButton];
    [stackView addArrangedSubview:removeItemButton];
    
    [self.view addSubview:stackView];
    [NSLayoutConstraint activateConstraints:@[
        [stackView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [stackView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];
    
    [stackView release];
}

- (void)didTriggerAddNavigationItemButton:(NSButton *)sender {
    NSMutableArray<NSToolbarIdentifier> *results = [self.navigationItem.navigationalItemIdentifiers mutableCopy];
    [results addObject:[NSString stringWithFormat:@"%@", [NSDate now]]];
    self.navigationItem.navigationalItemIdentifiers = results;
    [results release];
}

- (void)didTriggerRemoveNavigationItemButton:(NSButton *)sender {
    NSMutableArray<NSToolbarIdentifier> *results = [self.navigationItem.navigationalItemIdentifiers mutableCopy];
    [results removeLastObject];
    self.navigationItem.navigationalItemIdentifiers = results;
    [results release];
}

- (void)didTriggerAddItemButton:(NSButton *)sender {
    NSMutableArray<NSToolbarIdentifier> *results = [self.navigationItem.itemIdentifiers mutableCopy];
    [results addObject:[NSString stringWithFormat:@"%@", [NSDate now]]];
    self.navigationItem.itemIdentifiers = results;
    [results release];
}

- (void)didTriggerRemoveItemButton:(NSButton *)sender {
    NSMutableArray<NSToolbarIdentifier> *results = [self.navigationItem.itemIdentifiers mutableCopy];
    [results removeLastObject];
    self.navigationItem.itemIdentifiers = results;
    [results release];
}

@end
