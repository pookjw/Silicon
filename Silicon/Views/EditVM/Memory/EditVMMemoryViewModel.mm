//
//  EditVMMemoryViewModel.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/9/23.
//

#import "EditVMMemoryViewModel.hpp"

EditVMMemoryViewModel::EditVMMemoryViewModel(VirtualMachineMacModel *model) : _model([model retain]) {
    
}

EditVMMemoryViewModel::~EditVMMemoryViewModel() {
    [_model release];
}

void EditVMMemoryViewModel::memorySize(std::function<void (std::uint64_t)> completionHandler) {
    VirtualMachineMacModel *model = _model;
    
    [model.managedObjectContext performBlock:^{
        completionHandler(model.memorySize.unsignedLongLongValue);
    }];
}

void EditVMMemoryViewModel::setMemorySize(std::uint64_t memorySize, std::function<void (NSError * _Nullable)> completionHandler) {
    VirtualMachineMacModel *model = _model;
    
    [model.managedObjectContext performBlock:^{
        model.memorySize = [NSNumber numberWithUnsignedLongLong:memorySize];
        NSError * _Nullable error = nullptr;
        [model.managedObjectContext save:&error];
        completionHandler(error);
    }];
}
