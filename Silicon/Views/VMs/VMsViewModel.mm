//
//  VMsViewModel.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/3/23.
//

#import "VMsViewModel.hpp"
#import "PersistentDataManager.hpp"
#import "constants.hpp"

VMsViewModel::VMsViewModel() {
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.qualityOfService = NSOperationQualityOfServiceUtility;
    queue.maxConcurrentOperationCount = 1;
    [_queue release];
    _queue = [queue retain];
    [queue release];
    
    VMsViewModelDelegate *delegate = [VMsViewModelDelegate new];
    [_delegate release];
    _delegate = [delegate retain];
    [delegate release];
}

VMsViewModel::~VMsViewModel() {
    _delegate.controllerDidChangeContentWithSnapshot = nullptr;
    [_queue cancelAllOperations];
    [_dataSource release];
    [_fetchedResultsController release];
    [_queue release];
    [_delegate release];
}

void VMsViewModel::initialize(DataSource * _Nonnull dataSource, std::function<void (NSError * _Nullable)> completionHandler) {
    [_queue addOperationWithBlock:^{
        if (_isInitialized) {
            completionHandler([NSError errorWithDomain:SiliconErrorDomain code:SiliconAlreadyInitializedError userInfo:nullptr]);
            return;
        }
        
        [_dataSource release];
        _dataSource = [dataSource retain];
        
        NSOperationQueue *queue = _queue;
        void (^handler)(NSFetchedResultsController *, Snapshot *) = [^(NSFetchedResultsController *controller, Snapshot *snapshot) {
            [queue addOperationWithBlock:^{
                [dataSource applySnapshot:snapshot animatingDifferences:YES];
            }];
        } copy];
        
        _delegate.controllerDidChangeContentWithSnapshot = handler;
        [handler release];
        
        NSFetchRequest<VirtualMachineMacModel *> *fetchRequest = [NSFetchRequest<VirtualMachineMacModel *> fetchRequestWithEntityName:NSStringFromClass(VirtualMachineMacModel.class)];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdDate" ascending:YES];
        fetchRequest.sortDescriptors = @[sortDescriptor];
        [sortDescriptor release];
        fetchRequest.returnsObjectsAsFaults = YES;
        
        __block NSManagedObjectContext * _Nullable context = nullptr;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        PersistentDataManager::getInstance().context(^(NSManagedObjectContext *_context) {
            context = _context;
            dispatch_semaphore_signal(semaphore);
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_release(semaphore);
        
        NSFetchedResultsController<VirtualMachineMacModel *> *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                                             managedObjectContext:context
                                                                                                                               sectionNameKeyPath:nullptr
                                                                                                                                        cacheName:nullptr];
        
        fetchedResultsController.delegate = _delegate;
        
        NSError * _Nullable fetchError = nullptr;
        [fetchedResultsController performFetch:&fetchError];
        _fetchedResultsController = fetchedResultsController;
        
        if (fetchError) {
            completionHandler(fetchError);
            return;
        }
        
        _isInitialized = true;
        completionHandler(nullptr);
    }];
}

VirtualMachineMacModel * _Nullable VMsViewModel::virtualMachineMacModel(NSIndexPath * _Nonnull indexPath) {
    return [_fetchedResultsController objectAtIndexPath:indexPath];
}

void VMsViewModel::virtualMachineMacModel(NSIndexPath *indexPath, std::function<void (VirtualMachineMacModel * _Nullable)> handler) {
    [_queue addOperationWithBlock:^{
        handler([_fetchedResultsController objectAtIndexPath:indexPath]);
    }];
}
