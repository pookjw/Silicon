//
//  CreateVirtualMachineViewController.mm
//  Silicon
//
//  Created by Jinwoo Kim on 8/30/23.
//

#import "CreateVirtualMachineViewController.hpp"
#import "CreateVirtualMachineLocationViewController.hpp"

@interface CreateVirtualMachineViewController () <CreateVirtualMachineLocationViewControllerDelegate>
@property (retain) __kindof NSViewController * _Nullable currentContentViewController;
@end

@implementation CreateVirtualMachineViewController

- (void)dealloc {
    [_currentContentViewController release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CreateVirtualMachineLocationViewController *locationViewController = [CreateVirtualMachineLocationViewController new];
    locationViewController.delegate = self;
    [self presentContentViewController:locationViewController animated:NO];
    [locationViewController release];
}

- (void)presentContentViewController:(__kindof NSViewController *)contentViewController animated:(BOOL)animated {
    NSView *contentView = contentViewController.view;
    contentView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    [self.view addSubview:contentView];
    [self addChildViewController:contentViewController];
    
    BOOL _animated = animated && self.currentContentViewController;
    
    if (_animated) {
        [self transitionFromViewController:self.currentContentViewController
                          toViewController:contentViewController
                                   options:NSViewControllerTransitionCrossfade | NSViewControllerTransitionSlideForward
                         completionHandler:^{
            [self removeCurrentContentViewController];
            self.currentContentViewController = contentViewController;
        }];
    } else {
        [self removeCurrentContentViewController];
        self.currentContentViewController = contentViewController;
    }
}

- (void)removeCurrentContentViewController {
    [self.currentContentViewController removeFromParentViewController];
    [self.currentContentViewController.view removeFromSuperview];
}


#pragma mark - CreateVirtualMachineLocationViewControllerDelegate

- (void)locationViewControllerCreateNewVirtualMachine:(CreateVirtualMachineLocationViewController *)viewController {
    
}

- (void)locationViewController:(CreateVirtualMachineLocationViewController *)viewController didSelectLocalBundleURL:(NSURL *)localBundleURL {
    
}

@end
