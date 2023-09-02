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
#import "CreateVirtualMachineInstallationViewController.hpp"
#import <objc/runtime.h>

namespace _CreateVirtualMachineWindow {
namespace identifiers {
static NSToolbarItemIdentifier const locationNextItemIdentifier = @"CreateVirtualMachineWindow.locationNextItem";
}
}

@interface CreateVirtualMachineWindow () <RestoreImagesViewControllerDelegate>
@property (retain) NavigationController *navigationController;
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
    [super dealloc];
}

- (void)pushToLocationViewController {
    CreateVirtualMachineLocationViewController *locationViewContrller = [CreateVirtualMachineLocationViewController new];
    
    NSToolbarItem *locationNextItem = [[NSToolbarItem alloc] initWithItemIdentifier:_CreateVirtualMachineWindow::identifiers::locationNextItemIdentifier];
    locationNextItem.title = @"Next";
    locationNextItem.target = self;
    locationNextItem.action = @selector(didTriggerLocationNextItem:);
    
    NavigationItem *navigationItem = [NavigationItem new];
    navigationItem.itemIdentifiers = @[
        _CreateVirtualMachineWindow::identifiers::locationNextItemIdentifier
    ];
    navigationItem.toolbarItemHandler = ^NSToolbarItem * _Nullable (NSToolbarIdentifier identifier) {
        if ([identifier isEqualToString:_CreateVirtualMachineWindow::identifiers::locationNextItemIdentifier]) {
            return locationNextItem;
        } else {
            return nullptr;
        }
    };
    
    [locationNextItem release];
    
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

- (void)pushToInstallationViewControllerWithIPSWURL:(NSURL *)ipswURL {
    CreateVirtualMachineInstallationViewController *viewController = [[CreateVirtualMachineInstallationViewController alloc] initWithIPSWURL:ipswURL];
    [self.navigationController pushViewController:viewController completionHandler:nullptr];
    [viewController release];
}

- (void)didTriggerLocationNextItem:(NSToolbarItem *)sender {
    [self pushToRestoreImagesViewController];
}

#pragma mark - RestoreImagesViewControllerDelegate

- (void)restoreImagesViewController:(RestoreImagesViewController *)viewControoler didSelectRestoreImageModel:(RestoreImageModel *)restoreImageModel {
    [restoreImageModel.managedObjectContext performBlock:^{
        NSURL *ipswURL = restoreImageModel.URL;
        
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            [self pushToInstallationViewControllerWithIPSWURL:ipswURL];
        }];
    }];
}

@end
