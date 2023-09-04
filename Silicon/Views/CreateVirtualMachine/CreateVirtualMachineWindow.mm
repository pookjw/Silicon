//
//  CreateVirtualMachineWindow.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/2/23.
//

#import "CreateVirtualMachineWindow.hpp"
#import "NavigationController.hpp"
#import "NavigationItem.hpp"
#import "CreateVirtualMachineLocationViewController.hpp"
#import "RestoreImagesViewController.hpp"
#import "CreateVirtualMachineDiskConfigurationViewController.hpp"
#import "CreateVirtualMachineInstallationViewController.hpp"
#import <objc/runtime.h>
#import <optional>
#import <cinttypes>

namespace _CreateVirtualMachineWindow {
namespace identifiers {
static NSToolbarItemIdentifier const locationNextItemIdentifier = @"CreateVirtualMachineWindow.locationNextItem";
static NSToolbarItemIdentifier const diskConfigurationNextItemIdentifier = @"CreateVirtualMachineWindow.diskConfigurationNextItem";
}
}

@interface CreateVirtualMachineWindow () <RestoreImagesViewControllerDelegate, CreateVirtualMachineDiskConfigurationViewControllerDelegate>
@property (retain) NavigationController *navigationController;
@property (retain) RestoreImageModel * _Nullable restoreImageModel;
@property (assign) std::optional<std::uint64_t> storageSize;
@end

@implementation CreateVirtualMachineWindow

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag {
    if (self = [super initWithContentRect:contentRect styleMask:style backing:backingStoreType defer:flag]) {
        self.styleMask = NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskFullSizeContentView | NSWindowStyleMaskResizable | NSWindowStyleMaskTitled;
        self.movableByWindowBackground = YES;
        self.releasedWhenClosed = NO;
        self.titlebarAppearsTransparent = YES;
        self.contentMinSize = NSMakeSize(400.f, 400.f);
        
        NavigationController *navigationController = [NavigationController new];
        self.contentViewController = navigationController;
        self.navigationController = navigationController;
        [navigationController release];
        
        [self pushToLocationViewController];
    }
    
    return self;
}

- (void)dealloc {
    [_navigationController release];
    [_restoreImageModel release];
    [super dealloc];
}

- (void)pushToLocationViewController {
    CreateVirtualMachineLocationViewController *locationViewContrller = [CreateVirtualMachineLocationViewController new];
    
    NSToolbarItem *nextItem = [[NSToolbarItem alloc] initWithItemIdentifier:_CreateVirtualMachineWindow::identifiers::locationNextItemIdentifier];
    nextItem.title = @"Next";
    nextItem.target = self;
    nextItem.action = @selector(didTriggerLocationNextItem:);
    
    NavigationItem *navigationItem = [NavigationItem new];
    navigationItem.itemIdentifiers = @[
        _CreateVirtualMachineWindow::identifiers::locationNextItemIdentifier
    ];
    navigationItem.toolbarItemHandler = ^NSToolbarItem * _Nullable (NSToolbarIdentifier identifier) {
        if ([identifier isEqualToString:_CreateVirtualMachineWindow::identifiers::locationNextItemIdentifier]) {
            return nextItem;
        } else {
            return nullptr;
        }
    };
    
    [nextItem release];
    
    objc_setAssociatedObject(locationViewContrller, NavigationController.navigationItemAssociationKey, navigationItem, OBJC_ASSOCIATION_RETAIN);
    
    [navigationItem release];
    
    [self.navigationController pushViewController:locationViewContrller completionHandler:nullptr];
    [locationViewContrller release];
}

- (void)pushToRestoreImagesViewController {
    RestoreImagesViewController *viewController = [RestoreImagesViewController new];
    viewController.delegate = self;
    [self.navigationController pushViewController:viewController completionHandler:nullptr];
    [viewController release];
}

- (void)pushToDiskConfigurationViewController {
    CreateVirtualMachineDiskConfigurationViewController *viewController = [CreateVirtualMachineDiskConfigurationViewController new];
    viewController.delegate = self;
    self.storageSize = viewController.storageSize;
    
    //
    
    NSToolbarItem *nextItem = [[NSToolbarItem alloc] initWithItemIdentifier:_CreateVirtualMachineWindow::identifiers::diskConfigurationNextItemIdentifier];
    nextItem.title = @"Next";
    nextItem.target = self;
    nextItem.action = @selector(didTriggerDiskConfigurationNextItem:);
    
    NavigationItem *navigationItem = [NavigationItem new];
    navigationItem.itemIdentifiers = @[
        _CreateVirtualMachineWindow::identifiers::diskConfigurationNextItemIdentifier
    ];
    navigationItem.toolbarItemHandler = ^NSToolbarItem * _Nullable (NSToolbarIdentifier identifier) {
        if ([identifier isEqualToString:_CreateVirtualMachineWindow::identifiers::diskConfigurationNextItemIdentifier]) {
            return nextItem;
        } else {
            return nullptr;
        }
    };
    
    [nextItem release];
    
    objc_setAssociatedObject(viewController, NavigationController.navigationItemAssociationKey, navigationItem, OBJC_ASSOCIATION_RETAIN);
    
    [navigationItem release];
    
    //
    
    [self.navigationController pushViewController:viewController completionHandler:nullptr];
    [viewController release];
}

- (void)pushToInstallationViewControllerWithIPSWURL:(NSURL *)ipswURL storageSize:(std::uint64_t)storageSize {
    CreateVirtualMachineInstallationViewController *viewController = [[CreateVirtualMachineInstallationViewController alloc] initWithIPSWURL:ipswURL storageSize:storageSize];
    [self.navigationController pushViewController:viewController completionHandler:nullptr];
    [viewController release];
}

- (void)didTriggerLocationNextItem:(NSToolbarItem *)sender {
    [self pushToRestoreImagesViewController];
}

- (void)didTriggerDiskConfigurationNextItem:(NSToolbarItem *)sender {
    if (!self.storageSize.has_value()) {
        NSLog(@"No Storage Size.");
        return;
    }
    
    NSURL *ipswURL = self.restoreImageModel.URL;
    std::uint64_t storageSize = self.storageSize.value();
    
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        [self pushToInstallationViewControllerWithIPSWURL:ipswURL storageSize:storageSize];
    }];
}

#pragma mark - RestoreImagesViewControllerDelegate

- (void)restoreImagesViewController:(RestoreImagesViewController *)viewControoler didSelectRestoreImageModel:(RestoreImageModel *)restoreImageModel {
    self.restoreImageModel = restoreImageModel;
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        [self pushToDiskConfigurationViewController];
    }];
}

#pragma mark - CreateVirtualMachineDiskConfigurationViewControllerDelegate

- (void)createVirtualMachineDiskConfigurationViewController:(CreateVirtualMachineDiskConfigurationViewController *)diskConfigurationViewController didChangeStorageSize:(std::uint64_t)storageSize {
    self.storageSize = storageSize;
}

@end
