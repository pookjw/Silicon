//
//  VirtualMachineViewModel.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 9/3/23.
//

#import <Virtualization/Virtualization.h>
#import <functional>
#import "VirtualMachineMacModel.hpp"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

class VirtualMachineViewModel {
public:
    VirtualMachineViewModel(VirtualMachineMacModel *virtualMachineMacModel);
    ~VirtualMachineViewModel();
    
    void virtualMachine(std::function<void (VZVirtualMachine * _Nullable, NSError * _Nullable)>completionHandler);
    
    VirtualMachineViewModel(const VirtualMachineViewModel&) = delete;
    VirtualMachineViewModel& operator=(const VirtualMachineViewModel&) = delete;
private:
    VirtualMachineMacModel *_virtualMachineMacModel;
    VZVirtualMachine *_virtualMachine;
    NSOperationQueue *_queue;
};

NS_HEADER_AUDIT_END(nullability, sendability)
