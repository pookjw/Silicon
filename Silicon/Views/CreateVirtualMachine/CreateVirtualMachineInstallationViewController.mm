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
@property (retain) NSProgressIndicator *progressIndicator;
@property (assign) std::shared_ptr<CreateVirtualMachineInstallationViewModel> viewModel;
@property (assign) std::shared_ptr<Cancellable> installationCancellable;
@end

@implementation CreateVirtualMachineInstallationViewController

- (instancetype)initWithIPSWURL:(NSURL *)ipswURL {
    if (self = [self init]) {
        _viewModel = std::make_shared<CreateVirtualMachineInstallationViewModel>(ipswURL);
    }
    
    return self;
}

- (void)dealloc {
    [_progressIndicator release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSProgressIndicator *progressIndicator = [NSProgressIndicator new];
    progressIndicator.usesThreadedAnimation = YES;
    progressIndicator.style = NSProgressIndicatorStyleSpinning;
    progressIndicator.indeterminate = NO;
    progressIndicator.displayedWhenStopped = YES;
    progressIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:progressIndicator];
    [NSLayoutConstraint activateConstraints:@[
        [progressIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [progressIndicator.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];
    self.progressIndicator = progressIndicator;
    
    void (^progessHandler)(NSProgress *) = ^(NSProgress *progress) {
        progressIndicator.observedProgress = progress;
    };
    
    [progressIndicator release];
    
    void (^completionHandler)(NSError * _Nullable) = [^(NSError * _Nullable error) {
        NSLog(@"%@", error);
    } copy];
    
    _installationCancellable = self.viewModel.get()->startInstallation(progessHandler, completionHandler);
    
    [completionHandler release];
}

@end
