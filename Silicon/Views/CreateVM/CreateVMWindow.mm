//
//  CreateVMWindow.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/2/23.
//

#import "CreateVMWindow.hpp"
#import "NavigationController.hpp"
#import "NavigationItem.hpp"
#import "CreateVMLocationViewController.hpp"
#import "RestoreImagesViewController.hpp"
#import "CreateVMStorageSizeViewController.hpp"
#import "CreateVMInstallationViewController.hpp"
#import <objc/runtime.h>
#import <optional>
#import <cinttypes>

namespace _CreateVirtualMachineWindow {
namespace identifiers {
static NSToolbarItemIdentifier const locationNextItemIdentifier = @"CreateVirtualMachineWindow.locationNextItem";
static NSToolbarItemIdentifier const storageSizeNextItemIdentifier = @"CreateVirtualMachineWindow.storageSizeNextItem";
}
}

@interface CreateVMWindow () <RestoreImagesViewControllerDelegate, CreateVirtualMachineStorageSizeViewControllerDelegate>
@property (retain) NavigationController *navigationController;
@property (retain) RestoreImageModel * _Nullable restoreImageModel;
@property (assign) std::optional<std::uint64_t> storageSize;
@end

@implementation CreateVMWindow

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
    CreateVMLocationViewController *locationViewContrller = [CreateVMLocationViewController new];
    
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

- (void)pushToStorageSizeViewController {
    CreateVMStorageSizeViewController *viewController = [CreateVMStorageSizeViewController new];
    viewController.delegate = self;
    _storageSize = viewController.storageSize;
    
    //
    
    NSToolbarItem *nextItem = [[NSToolbarItem alloc] initWithItemIdentifier:_CreateVirtualMachineWindow::identifiers::storageSizeNextItemIdentifier];
    nextItem.title = @"Next";
    nextItem.target = self;
    nextItem.action = @selector(didTriggerStorageSizeNextItem:);
    
    NavigationItem *navigationItem = [NavigationItem new];
    navigationItem.itemIdentifiers = @[
        _CreateVirtualMachineWindow::identifiers::storageSizeNextItemIdentifier
    ];
    navigationItem.toolbarItemHandler = ^NSToolbarItem * _Nullable (NSToolbarIdentifier identifier) {
        if ([identifier isEqualToString:_CreateVirtualMachineWindow::identifiers::storageSizeNextItemIdentifier]) {
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
    CreateVMInstallationViewController *viewController = [[CreateVMInstallationViewController alloc] initWithIPSWURL:ipswURL storageSize:storageSize];
    [self.navigationController pushViewController:viewController completionHandler:nullptr];
    [viewController release];
}

- (void)didTriggerLocationNextItem:(NSToolbarItem *)sender {
    [self pushToRestoreImagesViewController];
}

- (void)didTriggerStorageSizeNextItem:(NSToolbarItem *)sender {
    if (!_storageSize.has_value()) {
        NSLog(@"No Storage Size.");
        return;
    }
    
    NSURL *ipswURL = self.restoreImageModel.URL;
    std::uint64_t storageSize = _storageSize.value();
    
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        [self pushToInstallationViewControllerWithIPSWURL:ipswURL storageSize:storageSize];
    }];
}

#pragma mark - RestoreImagesViewControllerDelegate

- (void)restoreImagesViewController:(RestoreImagesViewController *)viewControoler didSelectRestoreImageModel:(RestoreImageModel *)restoreImageModel {
    self.restoreImageModel = restoreImageModel;
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        [self pushToStorageSizeViewController];
    }];
}

#pragma mark - CreateVirtualMachineStorageSizeViewControllerDelegate

- (void)createVirtualMachineStorageSizeViewController:(CreateVMStorageSizeViewController *)viewController didChangeStorageSize:(std::uint64_t)storageSize {
    _storageSize = storageSize;
}

@end
