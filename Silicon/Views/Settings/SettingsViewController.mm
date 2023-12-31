//
//  SettingsViewController.mm
//  Silicon
//
//  Created by Jinwoo Kim on 8/28/23.
//

#import "SettingsViewController.hpp"
#import "RestoreImagesViewController.hpp"
#import "DaemonViewController.hpp"

@interface SettingsViewController ()
@property (retain) NSTabViewController *tabViewController;
@end

@implementation SettingsViewController

- (void)dealloc {
    [_tabViewController release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTabViewController];
    [self setupRestoreImagesViewController];
    [self setupDaemonViewController];
}

- (void)setupTabViewController {
    NSTabViewController *tabViewController = [NSTabViewController new];
    
    tabViewController.tabStyle = NSTabViewControllerTabStyleToolbar;
    
    NSView *contentView = tabViewController.view;
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:contentView];
    [NSLayoutConstraint activateConstraints:@[
        [contentView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [contentView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [contentView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [contentView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    self.tabViewController = tabViewController;
    [self addChildViewController:tabViewController];
    [tabViewController release];
}

- (void)setupRestoreImagesViewController {
    RestoreImagesViewController *restoreImagesViewController = [RestoreImagesViewController new];
    NSTabViewItem *tabViewItem = [NSTabViewItem tabViewItemWithViewController:restoreImagesViewController];
    [restoreImagesViewController release];
    
    tabViewItem.label = @"Images";
    tabViewItem.image = [NSImage imageWithSystemSymbolName:@"opticaldiscdrive" accessibilityDescription:nullptr];
    
    [self.tabViewController addTabViewItem:tabViewItem];
}

- (void)setupDaemonViewController {
    DaemonViewController *daemonViewController = [DaemonViewController new];
    NSTabViewItem *tabViewItem = [NSTabViewItem tabViewItemWithViewController:daemonViewController];
    [daemonViewController release];
    
    tabViewItem.label = @"Daemon";
    tabViewItem.image = [NSImage imageWithSystemSymbolName:@"ant" accessibilityDescription:nullptr];
    
    [self.tabViewController addTabViewItem:tabViewItem];
}

@end
