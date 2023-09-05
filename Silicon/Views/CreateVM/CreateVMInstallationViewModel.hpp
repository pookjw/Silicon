//
//  CreateVMInstallationViewModel.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 9/2/23.
//

#import <Foundation/Foundation.h>
#import <functional>
#import <memory>
#import <cinttypes>
#import "Cancellable.hpp"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

class CreateVMInstallationViewModel {
public:
    CreateVMInstallationViewModel(NSURL *ipswURL, std::uint64_t storageSize);
    ~CreateVMInstallationViewModel();
    
    std::shared_ptr<Cancellable> startInstallation(std::function<void (NSProgress *)> progressHandler, std::function<void (NSError * _Nullable)> completionHandler);
    
    CreateVMInstallationViewModel(const CreateVMInstallationViewModel&) = delete;
    CreateVMInstallationViewModel& operator=(const CreateVMInstallationViewModel&) = delete;
private:
    NSURL *_ipswURL;
    std::uint64_t _storageSize;
    NSOperationQueue *_queue;
};

NS_HEADER_AUDIT_END(nullability, sendability)
