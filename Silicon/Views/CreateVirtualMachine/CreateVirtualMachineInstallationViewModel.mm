//
//  CreateVirtualMachineLoadingViewModel.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/2/23.
//

#import "CreateVirtualMachineInstallationViewModel.hpp"
#import "constants.hpp"
#import "PersistentDataManager.hpp"
#import "VirtualMachineMacModel.hpp"
#import <Virtualization/Virtualization.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>
#import <atomic>

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

std::shared_ptr<Cancellable> CreateVirtualMachineInstallationViewModel::startInstallation(std::function<void (NSProgress * _Nonnull)> progressHandler, std::function<void (NSError * _Nullable)> completionHandler) {
    std::shared_ptr<std::atomic<NSProgress * _Nullable>> progress = std::make_shared<std::atomic<NSProgress * _Nullable>>(nullptr);
    std::shared_ptr<Cancellable> cancellable = std::make_shared<Cancellable>([progress]() {
        [progress.get()->load() cancel];
    });
    
    NSURL *ipswURL = _ipswURL;
    
    [_queue addOperationWithBlock:^{
        __block VZMacOSRestoreImage * _Nullable restoreImage = nullptr;
        __block NSError * _Nullable restoreImageError = nullptr;
        dispatch_semaphore_t restoreImageSemaphore = dispatch_semaphore_create(0);
        [ipswURL startAccessingSecurityScopedResource];
        [VZMacOSRestoreImage loadFileURL:ipswURL completionHandler:^(VZMacOSRestoreImage * _Nullable _restoreImage, NSError * _Nullable _restoreImageError) {
            [ipswURL stopAccessingSecurityScopedResource];
            restoreImage = [_restoreImage retain];
            restoreImageError = [_restoreImageError retain];
            dispatch_semaphore_signal(restoreImageSemaphore);
        }];
        dispatch_semaphore_wait(restoreImageSemaphore, DISPATCH_TIME_FOREVER);
        dispatch_release(restoreImageSemaphore);
        
        [restoreImage autorelease];
        [restoreImageError autorelease];
        
        if (restoreImageError) {
            completionHandler(restoreImageError);
            return;
        }
        
        //
        
        NSURL *applicationSupportURL = [NSFileManager.defaultManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].firstObject;
        NSURL *virtualMachinesURL = [applicationSupportURL URLByAppendingPathComponent:@"Virtual Machines" isDirectory:YES];
        NSURL *virtualMachineURL = [virtualMachinesURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", [NSDate now]] conformingToType:UTTypeBundle];
        
        NSLog(@"%@", virtualMachineURL);
        
        NSError * _Nullable ioError = nullptr;
        [NSFileManager.defaultManager createDirectoryAtURL:virtualMachineURL withIntermediateDirectories:YES attributes:nullptr error:&ioError];
        if (ioError) {
            completionHandler(ioError);
            return;
        }
        
        //
        
        VZMacOSConfigurationRequirements *configurationRequirements = restoreImage.mostFeaturefulSupportedConfiguration;
        VZMacHardwareModel *hardwareModel = configurationRequirements.hardwareModel;
        if (!hardwareModel.isSupported) {
            completionHandler([NSError errorWithDomain:SiliconErrorDomain code:SiliconNotSupportedHardware userInfo:nullptr]);
            return;
        }
        
        //
        
        NSURL *auxiliaryStorageURL = [virtualMachineURL URLByAppendingPathComponent:@"AuxiliaryStorage" isDirectory:NO];
        NSError * _Nullable auxiliaryStorageError = nullptr;
        VZMacAuxiliaryStorage *axiliaryStorage = [[VZMacAuxiliaryStorage alloc] initCreatingStorageAtURL:auxiliaryStorageURL
                                                                                           hardwareModel:hardwareModel
                                                                                                 options:VZMacAuxiliaryStorageInitializationOptionAllowOverwrite
                                                                                                   error:&auxiliaryStorageError];
        
        [axiliaryStorage autorelease];
        
        if (auxiliaryStorageError) {
            completionHandler(auxiliaryStorageError);
            return;
        }
        
        //
        
        VZMacMachineIdentifier *machineIdentifier = [VZMacMachineIdentifier new];
        [machineIdentifier autorelease];
        
        //
        
        NSURL *diskImageURL = [virtualMachineURL URLByAppendingPathComponent:@"image" conformingToType:UTTypeDiskImage];
        int fd = open([diskImageURL.path cStringUsingEncoding:NSUTF8StringEncoding], O_RDWR | O_CREAT, S_IRUSR | S_IWUSR);
        
        if (fd == -1) {
            completionHandler([NSError errorWithDomain:SiliconErrorDomain code:SiliconFileIOError userInfo:nullptr]);
            return;
        }
        
        int ft = ftruncate(fd, 128ull * 1024ull * 1024ull * 1024ull);
        if (ft) {
            completionHandler([NSError errorWithDomain:SiliconErrorDomain code:SiliconFileIOError userInfo:nullptr]);
            return;
        }
        
        if (close(fd)) {
            completionHandler([NSError errorWithDomain:SiliconErrorDomain code:SiliconFileIOError userInfo:nullptr]);
            return;
        }
        
        //
        
        VZMacPlatformConfiguration *platformConfiguration = [[VZMacPlatformConfiguration alloc] init];
        platformConfiguration.hardwareModel = hardwareModel;
        platformConfiguration.auxiliaryStorage = axiliaryStorage;
        platformConfiguration.machineIdentifier = machineIdentifier;
        [platformConfiguration autorelease];
        
        VZMacOSBootLoader *bootLoader = [[VZMacOSBootLoader alloc] init];
        [bootLoader autorelease];
        
        VZMacGraphicsDeviceConfiguration *graphicsDeviceConfiguration = [[VZMacGraphicsDeviceConfiguration alloc] init];
        VZMacGraphicsDisplayConfiguration *graphicsDisplayConfiguration = [[VZMacGraphicsDisplayConfiguration alloc] initWithWidthInPixels:1920 heightInPixels:1200 pixelsPerInch:80];
        graphicsDeviceConfiguration.displays = @[graphicsDisplayConfiguration];
        [graphicsDisplayConfiguration release];
        [graphicsDeviceConfiguration autorelease];
        
        NSError * _Nullable storageError = nullptr;
        VZDiskImageStorageDeviceAttachment *storageDeviceAttachment = [[VZDiskImageStorageDeviceAttachment alloc] initWithURL:diskImageURL
                                                                                                                     readOnly:NO
                                                                                                                  cachingMode:VZDiskImageCachingModeAutomatic
                                                                                                          synchronizationMode:VZDiskImageSynchronizationModeNone
                                                                                                                        error:&storageError];
        [storageDeviceAttachment autorelease];
        if (storageError) {
            completionHandler(storageError);
            return;
        }
        
        VZVirtioBlockDeviceConfiguration *storageDeviceConfiguration = [[VZVirtioBlockDeviceConfiguration alloc] initWithAttachment:storageDeviceAttachment];
        [storageDeviceConfiguration autorelease];
        
        VZVirtioNetworkDeviceConfiguration *networkConfiguration = [[VZVirtioNetworkDeviceConfiguration alloc] init];
        VZMACAddress *MACAddress = [[VZMACAddress alloc] initWithString:@"d6:a7:58:8e:78:d5"];
        networkConfiguration.MACAddress = MACAddress;
        [MACAddress release];
        
        VZNATNetworkDeviceAttachment *networkAttachment = [[VZNATNetworkDeviceAttachment alloc] init];
        networkConfiguration.attachment = networkAttachment;
        [networkAttachment release];
        [networkConfiguration autorelease];
        
        VZMacTrackpadConfiguration *trackpadConfiguration = [[VZMacTrackpadConfiguration alloc] init];
        [trackpadConfiguration autorelease];
        
        VZMacKeyboardConfiguration *keyboardConfiguration = [[VZMacKeyboardConfiguration alloc] init];
        [keyboardConfiguration autorelease];
        
        //
        
        VZVirtualMachineConfiguration *virtualMachineConfiguration = [VZVirtualMachineConfiguration new];
        
        virtualMachineConfiguration.platform = platformConfiguration;
        virtualMachineConfiguration.CPUCount = VZVirtualMachineConfiguration.maximumAllowedCPUCount;
        virtualMachineConfiguration.memorySize = VZVirtualMachineConfiguration.maximumAllowedMemorySize;
        virtualMachineConfiguration.bootLoader = bootLoader;
        virtualMachineConfiguration.graphicsDevices = @[graphicsDeviceConfiguration];
        virtualMachineConfiguration.storageDevices = @[storageDeviceConfiguration];
        virtualMachineConfiguration.networkDevices = @[networkConfiguration];
        virtualMachineConfiguration.pointingDevices = @[trackpadConfiguration];
        virtualMachineConfiguration.keyboards = @[keyboardConfiguration];
        
        [virtualMachineConfiguration autorelease];
        
        NSError * _Nullable validationError = nullptr;
        [virtualMachineConfiguration validateWithError:&validationError];
        if (validationError) {
            completionHandler(validationError);
            return;
        }
        
        VZVirtualMachine *machine = [[VZVirtualMachine alloc] initWithConfiguration:virtualMachineConfiguration];
        NSURL *restoreImageURL = restoreImage.URL;
        
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            [restoreImageURL startAccessingSecurityScopedResource];
            VZMacOSInstaller *installer = [[VZMacOSInstaller alloc] initWithVirtualMachine:machine restoreImageURL:restoreImageURL];
            
            if (cancellable.get()->isCancelled()) {
                [restoreImage.URL stopAccessingSecurityScopedResource];
                completionHandler([NSError errorWithDomain:SiliconErrorDomain code:SiliconUserCancelledError userInfo:nullptr]);
                return;
            }
            
            [progress.get()->load() release];
            progress.get()->store([installer.progress retain]);
            progressHandler(installer.progress);
            
            [installer installWithCompletionHandler:^(NSError * _Nullable error) {
                [restoreImageURL stopAccessingSecurityScopedResource];
                
                [progress.get()->load() release];
                progress.get()->store(nullptr);
                
                if (error) {
                    completionHandler(error);
                    return;
                }
                
                PersistentDataManager::getInstance().context(^(NSManagedObjectContext *context) {
                    [context performBlock:^{
                        VirtualMachineMacModel *model = [[VirtualMachineMacModel alloc] initWithContext:context];
                        model.createdDate = [NSDate now];
                        model.bundleURL = virtualMachineURL;
                        model.hardwareModel = hardwareModel;
                        model.axiliaryStorageURL = auxiliaryStorageURL;
                        model.machineIdentifier = machineIdentifier;
                        model.diskImageURL = diskImageURL;
                        model.displayWidthInPixels = @(graphicsDisplayConfiguration.widthInPixels);
                        model.displayHeightInPixels = @(graphicsDisplayConfiguration.heightInPixels);
                        model.displayPixelsForInch = @(graphicsDisplayConfiguration.pixelsPerInch);
                        model.MACAddress = MACAddress;
                        
                        NSError * _Nullable error = nullptr;
                        [context save:&error];
                        [model release];
                        completionHandler(error);
                    }];
                });
            }];
            
            [installer release];
        }];
        
        [machine release];
    }];
    
    return cancellable;
}
