//
//  VMViewModel.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 9/3/23.
//

#import <Virtualization/Virtualization.h>
#import <functional>
#import "VirtualMachineMacModel.hpp"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

class VMViewModel {
public:
    VMViewModel(VirtualMachineMacModel *virtualMachineMacModel);
    ~VMViewModel();
    
    void virtualMachine(std::function<void (VZVirtualMachine * _Nullable, NSError * _Nullable)>completionHandler);
    
    VMViewModel(const VMViewModel&) = delete;
    VMViewModel& operator=(const VMViewModel&) = delete;
private:
    VirtualMachineMacModel *_virtualMachineMacModel;
    VZVirtualMachine *_virtualMachine;
    NSOperationQueue *_queue;
};

NS_HEADER_AUDIT_END(nullability, sendability)
