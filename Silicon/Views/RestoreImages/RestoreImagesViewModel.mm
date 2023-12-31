//
//  RestoreImagesViewModel.mm
//  Silicon
//
//  Created by Jinwoo Kim on 8/29/23.
//

#import "RestoreImagesViewModel.hpp"
#import "constants.hpp"
#import "PersistentDataManager.hpp"
#import <Virtualization/Virtualization.h>
#import <atomic>

RestoreImagesViewModel::RestoreImagesViewModel() {
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.qualityOfService = NSOperationQualityOfServiceUtility;
    queue.maxConcurrentOperationCount = 1;
    [_queue release];
    _queue = [queue retain];
    [queue release];
    
    RestoreImagesViewModelDelegate *delegate = [RestoreImagesViewModelDelegate new];
    [_delegate release];
    _delegate = [delegate retain];
    [delegate release];
}

RestoreImagesViewModel::~RestoreImagesViewModel() {
    _delegate.controllerDidChangeContentWithSnapshot = nullptr;
    [_queue cancelAllOperations];
    [_dataSource release];
    [_fetchedResultsController release];
    [_queue release];
    [_delegate release];
}

void RestoreImagesViewModel::initialize(DataSource *dataSource, std::function<void (NSError * _Nullable)> completionHandler) {
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
        
        NSFetchRequest<RestoreImageModel *> *fetchRequest = [NSFetchRequest<RestoreImageModel *> fetchRequestWithEntityName:NSStringFromClass(RestoreImageModel.class)];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"versions.buildVersion" ascending:YES];
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
        
        NSFetchedResultsController<RestoreImageModel *> *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
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

RestoreImageModel * _Nullable RestoreImagesViewModel::restoreImageModel(NSIndexPath *indexPath) {
    return [_fetchedResultsController objectAtIndexPath:indexPath];
}

void RestoreImagesViewModel::restoreImageModel(NSIndexPath * _Nonnull indexPath, std::function<void (RestoreImageModel * _Nullable)> completionHandler) {
    NSFetchedResultsController<RestoreImageModel *> *fetchedResultsController = _fetchedResultsController;
    
    [_queue addBarrierBlock:^{
        RestoreImageModel * _Nullable result = [fetchedResultsController objectAtIndexPath:indexPath];
        completionHandler(result);
    }];
}

void RestoreImagesViewModel::addFromLocalIPSWURLs(NSArray<NSURL *> *localURLs, std::function<void (NSError * _Nullable)> completionHandler) {
    [_queue addOperationWithBlock:^{
        [localURLs enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSError * _Nullable error = nullptr;
            
            if (error) {
                completionHandler(error);
                *stop = YES;
                return;
            }
            
            [VZMacOSRestoreImage loadFileURL:obj completionHandler:^(VZMacOSRestoreImage * _Nullable restoreImage, NSError * _Nullable error) {
                if (error) {
                    completionHandler(error);
                    return;
                }
                
                PersistentDataManager::getInstance().context(^(NSManagedObjectContext *context) {
                    [context performBlock:^{
                        RestoreImageModel *restoreImageModel = [[RestoreImageModel alloc] initWithContext:context];
                        restoreImageModel.versions = @{
                            _RestoreImageModel::versionKeys::buildVersionKey: restoreImage.buildVersion,
                            _RestoreImageModel::versionKeys::majorVersionKey: @(restoreImage.operatingSystemVersion.majorVersion),
                            _RestoreImageModel::versionKeys::minorVersionKey: @(restoreImage.operatingSystemVersion.minorVersion),
                            _RestoreImageModel::versionKeys::patchVersionKey: @(restoreImage.operatingSystemVersion.patchVersion),
                        };
                        restoreImageModel.URL = restoreImage.URL;
                        
                        [restoreImageModel release];
                        
                        NSError * _Nullable error = nullptr;
                        [context save:&error];
                        completionHandler(error);
                    }];
                });
            }];
        }];
    }];
}

std::shared_ptr<Cancellable> RestoreImagesViewModel::addFromRemote(std::function<void (NSProgress *)> progressHandler, std::function<void (NSError * _Nullable)> completionHandler) {
    std::shared_ptr<std::atomic<NSURLSessionDownloadTask * _Nullable>> _downloadTask = std::make_shared<std::atomic<NSURLSessionDownloadTask * _Nullable>>(nullptr);
    
    std::shared_ptr<Cancellable> cancellable = std::make_shared<Cancellable>([_downloadTask]{
        [_downloadTask.get()->load() cancel];
    });
    
    [VZMacOSRestoreImage fetchLatestSupportedWithCompletionHandler:^(VZMacOSRestoreImage * _Nullable restoreImage, NSError * _Nullable error) {
        if (error) {
            completionHandler(error);
            return;
        }
        
        if (cancellable.get()->isCancelled()) {
            completionHandler([NSError errorWithDomain:SiliconErrorDomain code:SiliconUserCancelledError userInfo:nullptr]);
            return;
        }
        
        NSURLSessionConfiguration *configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration;
        configuration.allowsExpensiveNetworkAccess = NO;
        configuration.waitsForConnectivity = NO;
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:restoreImage.URL completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            [_downloadTask.get()->load() release];
            _downloadTask.get()->store(nullptr);
            
            if (error) {
                completionHandler(error);
                return;
            }
            
            NSURL *applicationSupportURL = [NSFileManager.defaultManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].firstObject;
            NSURL *ipswsURL = [applicationSupportURL URLByAppendingPathComponent:@"ipsws" isDirectory:YES];
            
            NSError * _Nullable ioError = nullptr;
            
            if (![NSFileManager.defaultManager fileExistsAtPath:ipswsURL.path]) {
                [NSFileManager.defaultManager createDirectoryAtURL:ipswsURL withIntermediateDirectories:YES attributes:nullptr error:&ioError];
                
                if (ioError) {
                    completionHandler(ioError);
                    return;
                }
            }
            
            NSURL *URL = [ipswsURL URLByAppendingPathComponent:response.suggestedFilename];
            [NSFileManager.defaultManager moveItemAtURL:location toURL:URL error:&ioError];
            
            if (ioError) {
                completionHandler(ioError);
                return;
            }
            
            PersistentDataManager::getInstance().context(^(NSManagedObjectContext *context) {
                [context performBlock:^{
                    RestoreImageModel *restoreImageModel = [[RestoreImageModel alloc] initWithContext:context];
                    restoreImageModel.versions = @{
                        _RestoreImageModel::versionKeys::buildVersionKey: restoreImage.buildVersion,
                        _RestoreImageModel::versionKeys::majorVersionKey: @(restoreImage.operatingSystemVersion.majorVersion),
                        _RestoreImageModel::versionKeys::minorVersionKey: @(restoreImage.operatingSystemVersion.minorVersion),
                        _RestoreImageModel::versionKeys::patchVersionKey: @(restoreImage.operatingSystemVersion.patchVersion),
                    };
                    restoreImageModel.URL = URL;
                    [restoreImageModel release];
                    
                    NSError * _Nullable error = nullptr;
                    [context save:&error];
                    completionHandler(error);
                }];
            });
        }];
        
        [_downloadTask.get()->load() release];
        _downloadTask.get()->store([downloadTask retain]);
        progressHandler(downloadTask.progress);
        [downloadTask resume];
        [session finishTasksAndInvalidate];
    }];
    
    return cancellable;
}
