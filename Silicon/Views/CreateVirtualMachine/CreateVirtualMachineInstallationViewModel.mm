//
//  CreateVirtualMachineLoadingViewModel.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/2/23.
//

#import "CreateVirtualMachineInstallationViewModel.hpp"
#import <Virtualization/Virtualization.h>

CreateVirtualMachineInstallationViewModel::CreateVirtualMachineInstallationViewModel(NSURL *ipswURL) : _ipswURL([ipswURL copy]) {
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.qualityOfService = NSOperationQualityOfServiceUtility;
    queue.maxConcurrentOperationCount = 1;
    [_queue release];
    _queue = [queue retain];
    [queue release];
};

CreateVirtualMachineInstallationViewModel::~CreateVirtualMachineInstallationViewModel() {
    [_ipswURL release];
}

void CreateVirtualMachineInstallationViewModel::startInstallation(std::function<void (NSProgress * _Nonnull)> progressHandler, std::function<void (NSError * _Nullable)> completionHandler) {
    completionHandler(nullptr);
}
