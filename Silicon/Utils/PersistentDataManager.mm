//
//  PersistentDataManager.mm
//  Silicon
//
//  Created by Jinwoo Kim on 8/28/23.
//

#import "PersistentDataManager.hpp"
#import "RestoreImageModel.hpp"

PersistentDataManager::PersistentDataManager() {
    NSURL *applicationSupportURL = [NSFileManager.defaultManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].firstObject;
    
    NSURL *containerURL = [[applicationSupportURL URLByAppendingPathComponent:@"PersistentDataManager" isDirectory:NO] URLByAppendingPathExtension:@"sqlite"];
    
    NSPersistentStoreDescription *persistentStoreDescription = [[NSPersistentStoreDescription alloc] initWithURL:containerURL];
    [persistentStoreDescription setOption:@YES forKey:NSPersistentHistoryTrackingKey];
    
    NSPersistentContainer *container = [[NSPersistentContainer alloc] initWithName:@"PersistentDataManager" managedObjectModel:managedObjectModel()];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [container.persistentStoreCoordinator addPersistentStoreWithDescription:persistentStoreDescription completionHandler:^(NSPersistentStoreDescription * _Nonnull description, NSError * _Nullable error) {
        if (error) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:error.localizedDescription userInfo:nullptr];
            return;
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    dispatch_release(semaphore);
    
    NSManagedObjectContext *context = container.newBackgroundContext;
    
    _container = [container retain];
    _context = [context retain];
    
    [container release];
    [context release];
}

PersistentDataManager::~PersistentDataManager() {
    [_context release];
    [_container release];
}

NSManagedObjectContext *PersistentDataManager::context() {
    return _context;
}

NSManagedObjectModel *PersistentDataManager::managedObjectModel() {
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel new];
    
    managedObjectModel.entities = @[
        RestoreImageModel.entity
    ];
    
    return [managedObjectModel autorelease];
}
