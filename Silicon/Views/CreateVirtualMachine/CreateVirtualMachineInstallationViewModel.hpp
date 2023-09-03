//
//  CreateVirtualMachineInstallationViewModel.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 9/2/23.
//

#import <Foundation/Foundation.h>
#import <functional>
#import <memory>
#import "Cancellable.hpp"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

class CreateVirtualMachineInstallationViewModel {
public:
    CreateVirtualMachineInstallationViewModel(NSURL *ipswURL);
    ~CreateVirtualMachineInstallationViewModel();
    
    std::shared_ptr<Cancellable> startInstallation(std::function<void (NSProgress *)> progressHandler, std::function<void (NSError * _Nullable)> completionHandler);
    
    CreateVirtualMachineInstallationViewModel(const CreateVirtualMachineInstallationViewModel&) = delete;
    CreateVirtualMachineInstallationViewModel& operator=(const CreateVirtualMachineInstallationViewModel&) = delete;
private:
    NSURL *_ipswURL;
    NSOperationQueue *_queue;
};

NS_HEADER_AUDIT_END(nullability, sendability)
