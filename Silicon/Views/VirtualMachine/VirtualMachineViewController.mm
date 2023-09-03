//
//  VirtualMachineViewController.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/3/23.
//

#import "VirtualMachineViewController.hpp"
#import "VirtualMachineViewModel.hpp"
#import <Virtualization/Virtualization.h>
#import <memory>

@interface VirtualMachineViewController () <VZVirtualMachineDelegate>
@property (retain) VZVirtualMachineView *virtualMachineView;
@property (assign) std::shared_ptr<VirtualMachineViewModel> viewModel;
@end

@implementation VirtualMachineViewController

- (instancetype)initWithVirtualMachineMacModel:(VirtualMachineMacModel *)virtualMachineMacModel {
    if (self = [super initWithNibName:nullptr bundle:nullptr]) {
        _viewModel = std::make_shared<VirtualMachineViewModel>(virtualMachineMacModel);
    }
    
    return self;
}

- (void)dealloc {
    [_virtualMachineView.virtualMachine stopWithCompletionHandler:^(NSError * _Nullable errorOrNil) {
        if (errorOrNil) {
            assert(errorOrNil);
            return;
        }
    }];
    [_virtualMachineView release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupVirtualMachineView];
    
    VZVirtualMachineView *virtualMachineView = self.virtualMachineView;
    self.viewModel.get()->virtualMachine(^(VZVirtualMachine * _Nullable virtualMachine, NSError * _Nullable error) {
        if (error) {
            assert(error);
            return;
        }
        
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            virtualMachineView.virtualMachine = virtualMachine;
            
            VZMacOSVirtualMachineStartOptions *options = [VZMacOSVirtualMachineStartOptions new];
            options.startUpFromMacOSRecovery = YES;
            
            [virtualMachine startWithOptions:options completionHandler:^(NSError * _Nullable errorOrNil) {
                if (errorOrNil) {
                    assert(errorOrNil);
                    return;
                }
            }];
            
            [options release];
        }];
    });
}

- (void)setupVirtualMachineView {
    VZVirtualMachineView *virtualMachineView = [VZVirtualMachineView new];
    virtualMachineView.capturesSystemKeys = YES;
    virtualMachineView.automaticallyReconfiguresDisplay = YES;
    virtualMachineView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:virtualMachineView];
    [NSLayoutConstraint activateConstraints:@[
        [virtualMachineView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [virtualMachineView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [virtualMachineView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [virtualMachineView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    self.virtualMachineView = virtualMachineView;
    [virtualMachineView release];
}

#pragma mark - VZVirtualMachineDelegate

- (void)guestDidStopVirtualMachine:(VZVirtualMachine *)virtualMachine {
    NSLog(@"Did stop");
}

- (void)virtualMachine:(VZVirtualMachine *)virtualMachine didStopWithError:(NSError *)error {
    assert(error);
}

- (void)virtualMachine:(VZVirtualMachine *)virtualMachine networkDevice:(VZNetworkDevice *)networkDevice attachmentWasDisconnectedWithError:(NSError *)error {
    assert(error);
}

@end
