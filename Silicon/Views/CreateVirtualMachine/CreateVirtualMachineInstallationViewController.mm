//
//  CreateVirtualMachineLoadingViewController.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/2/23.
//

#import "CreateVirtualMachineInstallationViewController.hpp"
#import "CreateVirtualMachineInstallationViewModel.hpp"
#import <memory>

@interface CreateVirtualMachineInstallationViewController ()
@property (assign) std::shared_ptr<CreateVirtualMachineInstallationViewModel> viewModel;
@end

@implementation CreateVirtualMachineInstallationViewController

- (instancetype)initWithIPSWURL:(NSURL *)ipswURL {
    if (self = [self init]) {
        _viewModel = std::make_shared<CreateVirtualMachineInstallationViewModel>(ipswURL);
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    void (^progessHandler)(NSProgress *) = ^(NSProgress *progress) {
        
    };
    
    // Capture
    
    void (^completionHandler)(NSError * _Nullable) = [^(NSError * _Nullable error) {
        
    } copy];
    
    //
    
    self.viewModel.get()->startInstallation(progessHandler, completionHandler);
    
    [completionHandler release];
}

@end
