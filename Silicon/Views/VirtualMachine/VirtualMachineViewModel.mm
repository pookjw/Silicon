//
//  VirtualMachineViewModel.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/3/23.
//

#import "VirtualMachineViewModel.hpp"
#import "constants.hpp"

VirtualMachineViewModel::VirtualMachineViewModel(VirtualMachineMacModel *virtualMachineMacModel) : _virtualMachineMacModel([virtualMachineMacModel retain]) {
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.qualityOfService = NSOperationQualityOfServiceUtility;
    queue.maxConcurrentOperationCount = 1;
    [_queue release];
    _queue = [queue retain];
    [queue release];
}

VirtualMachineViewModel::~VirtualMachineViewModel() {
    [_queue cancelAllOperations];
    [_virtualMachineMacModel release];
    [_virtualMachine release];
    [_queue release];
}

void VirtualMachineViewModel::virtualMachine(std::function<void (VZVirtualMachine * _Nullable, NSError * _Nullable)> completionHandler) {
    VirtualMachineMacModel *virtualMachineMacModel = _virtualMachineMacModel;
    
    [_queue addOperationWithBlock:^{
        NSManagedObjectContext * _Nullable context = virtualMachineMacModel.managedObjectContext;
        if (!context) {
            completionHandler(nullptr, [NSError errorWithDomain:SiliconErrorDomain code:SiliconDeletedVirtualMachineModel userInfo:nullptr]);
            return;
        }
        
        [context performBlock:^{
            NSError * _Nullable error = nullptr;
            VZVirtualMachineConfiguration *configuration = [virtualMachineMacModel virtualMachineConfigurationWithError:&error];
            
            VZMacTrackpadConfiguration *trackpadConfiguration = [[VZMacTrackpadConfiguration alloc] init];
            
            VZMacKeyboardConfiguration *keyboardConfiguration = [[VZMacKeyboardConfiguration alloc] init];
            
            configuration.pointingDevices = @[trackpadConfiguration];
            [trackpadConfiguration release];
            configuration.keyboards = @[keyboardConfiguration];
            [keyboardConfiguration release];
            
            
            if (error) {
                completionHandler(nullptr, error);
                return;
            }
            
            [configuration validateWithError:&error];
            if (error) {
                completionHandler(nullptr, error);
                return;
            }
            
            VZVirtualMachine *virtualMachine = [[VZVirtualMachine alloc] initWithConfiguration:configuration];
            completionHandler([virtualMachine autorelease], nullptr);
        }];
    }];
}
