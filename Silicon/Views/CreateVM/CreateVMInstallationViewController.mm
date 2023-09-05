//
//  CreateVMInstallationViewController.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/2/23.
//

#import "CreateVMInstallationViewController.hpp"
#import "CreateVMInstallationViewModel.hpp"
#import <memory>

@interface CreateVMInstallationViewController ()
@property (retain) NSProgressIndicator *progressIndicator;
@property (assign) std::shared_ptr<CreateVMInstallationViewModel> viewModel;
@property (assign) std::shared_ptr<Cancellable> installationCancellable;
@end

@implementation CreateVMInstallationViewController

- (instancetype)initWithIPSWURL:(NSURL *)ipswURL storageSize:(std::uint64_t)storageSize {
    if (self = [self init]) {
        _viewModel = std::make_shared<CreateVMInstallationViewModel>(ipswURL, storageSize);
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
