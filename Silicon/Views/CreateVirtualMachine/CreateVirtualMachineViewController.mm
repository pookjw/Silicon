//
//  CreateVirtualMachineViewController.mm
//  Silicon
//
//  Created by Jinwoo Kim on 8/30/23.
//

#import "CreateVirtualMachineViewController.hpp"
#import "NavigationController.hpp"
#import "NavigationItem.hpp"
#import "CreateVirtualMachineLocationViewController.hpp"
#import "RestoreImagesViewController.hpp"
#import "TestNavigationViewController.hpp"
#import <objc/runtime.h>

namespace _CreateVirtualMachineViewController {
namespace identifiers {
static NSToolbarItemIdentifier const locationNextButtonItemIdentifier = @"CreateVirtualMachineViewController.locationNextButtonItem";
}
}

@interface CreateVirtualMachineViewController () <RestoreImagesViewControllerDelegate>
@property (retain) NavigationController *navigationController;
@end

@implementation CreateVirtualMachineViewController

- (void)dealloc {
    [_navigationController release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationController];
    [self pushToLocationViewController];
}

- (void)setupNavigationController {
    NavigationController *navigationController = [NavigationController new];
    navigationController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:navigationController.view];
    
    [NSLayoutConstraint activateConstraints:@[
        [navigationController.view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [navigationController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [navigationController.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [navigationController.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
    
    self.navigationController = navigationController;
    [navigationController release];
}

- (void)pushToLocationViewController {
    CreateVirtualMachineLocationViewController *locationViewContrller = [CreateVirtualMachineLocationViewController new];
    
    NSToolbarItem *locationNextItem = [[NSToolbarItem alloc] initWithItemIdentifier:_CreateVirtualMachineViewController::identifiers::locationNextButtonItemIdentifier];
    locationNextItem.title = @"Next";
    locationNextItem.target = self;
    locationNextItem.action = @selector(didTriggerLocationNextItem:);
    
    NavigationItem *navigationItem = [NavigationItem new];
    navigationItem.itemIdentifiers = @[
        _CreateVirtualMachineViewController::identifiers::locationNextButtonItemIdentifier
    ];
    navigationItem.toolbarItemHandler = ^NSToolbarItem * _Nullable (NSToolbarIdentifier identifier) {
        if ([identifier isEqualToString:_CreateVirtualMachineViewController::identifiers::locationNextButtonItemIdentifier]) {
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

- (void)didTriggerLocationNextItem:(NSToolbarItem *)sender {
    [self pushToRestoreImagesViewController];
}

#pragma mark - RestoreImagesViewControllerDelegate

- (void)restoreImagesViewController:(RestoreImagesViewController *)viewControoler didSelectRestoreImageModel:(RestoreImageModel *)restoreImageModel {
    [NSOperationQueue.mainQueue addOperationWithBlock:^{
        TestNavigationViewController *vc = [TestNavigationViewController new];
        [self.navigationController pushViewController:vc completionHandler:nullptr];
        [vc release];
    }];
}

@end
