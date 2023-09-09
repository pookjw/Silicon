//
//  EditVMMemoryViewModel.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 9/9/23.
//

#import <Foundation/Foundation.h>
#import "VirtualMachineMacModel.hpp"
#import <cinttypes>
#import <functional>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

class EditVMMemoryViewModel {
public:
    EditVMMemoryViewModel(VirtualMachineMacModel *model);
    ~EditVMMemoryViewModel();
    
    void memorySize(std::function<void (std::uint64_t)> completionHandler);
    void setMemorySize(std::uint64_t memorySize, std::function<void (NSError * _Nullable)> completionHandler);
    
    EditVMMemoryViewModel(const EditVMMemoryViewModel&) = delete;
    EditVMMemoryViewModel& operator=(const EditVMMemoryViewModel&) = delete;
private:
    VirtualMachineMacModel *_model;
};

NS_HEADER_AUDIT_END(nullability, sendability)
