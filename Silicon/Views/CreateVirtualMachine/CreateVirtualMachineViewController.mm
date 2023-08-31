//
//  CreateVirtualMachineViewController.mm
//  Silicon
//
//  Created by Jinwoo Kim on 8/30/23.
//

#import "CreateVirtualMachineViewController.hpp"
#import "NavigationController.hpp"
#import "CreateVirtualMachineLocationViewController.hpp"
#import "RestoreImagesViewController.hpp"

@interface CreateVirtualMachineViewController () <CreateVirtualMachineLocationViewControllerDelegate>
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
    locationViewContrller.delegate = self;
    [self.navigationController pushViewController:locationViewContrller completionHandler:nullptr];
    [locationViewContrller release];
}

- (void)pushToRestoreImagesViewController {
    RestoreImagesViewController *viewController = [RestoreImagesViewController new];
    [self.navigationController pushViewController:viewController completionHandler:nullptr];
    [viewController release];
}

#pragma mark - CreateVirtualMachineLocationViewControllerDelegate

- (void)locationViewControllerCreateNewVirtualMachine:(CreateVirtualMachineLocationViewController *)viewController {
    [self pushToRestoreImagesViewController];
}

- (void)locationViewControllerAddExistingVirtualMachine:(CreateVirtualMachineLocationViewController *)viewController {
    
}

@end
