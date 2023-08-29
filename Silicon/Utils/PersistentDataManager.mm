//
//  PersistentDataManager.mm
//  Silicon
//
//  Created by Jinwoo Kim on 8/28/23.
//

#import "PersistentDataManager.hpp"
#import "RestoreImageModel.hpp"
#import "constants.hpp"

PersistentDataManager::PersistentDataManager() {
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.name = @"PersistentDataManager";
    queue.qualityOfService = NSOperationQualityOfServiceUtility;
    [_queue release];
    _queue = [queue retain];
    [queue release];
}

PersistentDataManager::~PersistentDataManager() {
    [_queue cancelAllOperations];
    [_context release];
    [_container release];
    [_queue release];
}

NSManagedObjectContext *PersistentDataManager::context() {
    return _context;
}

NSOperationQueue *PersistentDataManager::queue() {
    return _queue;
}

void PersistentDataManager::initialize(std::function<void (NSError * _Nullable)> completionHandler) {
    [_queue addBarrierBlock:^{
        if (_isInitialized) {
            completionHandler([NSError errorWithDomain:SiliconErrorDomain code:SiliconAlreadyInitializedError userInfo:nullptr]);
            return;
        }
        
        NSURL *applicationSupportURL = [NSFileManager.defaultManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].firstObject;
        NSURL *containerURL = [[applicationSupportURL URLByAppendingPathComponent:@"PersistentDataManager" isDirectory:NO] URLByAppendingPathExtension:@"sqlite"];
        
        NSLog(@"%@", containerURL);
        
        NSPersistentStoreDescription *persistentStoreDescription = [[NSPersistentStoreDescription alloc] initWithURL:containerURL];
        [persistentStoreDescription setOption:@YES forKey:NSPersistentHistoryTrackingKey];
        
        NSPersistentContainer *container = [[NSPersistentContainer alloc] initWithName:@"PersistentDataManager_v0" managedObjectModel:_managedObjectModel()];
        
        __block NSError * _Nullable error = nullptr;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [container.persistentStoreCoordinator addPersistentStoreWithDescription:persistentStoreDescription completionHandler:^(NSPersistentStoreDescription * _Nonnull description, NSError * _Nullable _error) {
            error = _error;
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_release(semaphore);
        
        if (error) {
            [container release];
            completionHandler(error);
            return;
        }
        
        NSManagedObjectContext *context = container.newBackgroundContext;
        
        [_container release];
        _container = [container retain];
        
        [_context release];
        _context = [context retain];
        
        [container release];
        [context release];
        
        _isInitialized = true;
        completionHandler(nullptr);
    }];
}

NSManagedObjectModel *PersistentDataManager::_managedObjectModel() {
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel new];
    
    managedObjectModel.entities = @[
        RestoreImageModel._entity
    ];
    
    return [managedObjectModel autorelease];
}
