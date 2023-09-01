//
//  RestoreImagesViewModel.mm
//  Silicon
//
//  Created by Jinwoo Kim on 8/29/23.
//

#import "RestoreImagesViewModel.hpp"
#import "constants.hpp"
#import <Virtualization/Virtualization.h>

RestoreImagesViewModel::RestoreImagesViewModel() : _dataManager(PersistentDataManager::getInstance()) {
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.qualityOfService = NSOperationQualityOfServiceUtility;
    queue.maxConcurrentOperationCount = 1;
    [_queue release];
    _queue = [queue retain];
    [queue release];
    
    RestoreImagesViewModelDelegate *delegate = [RestoreImagesViewModelDelegate new];
    _delegate = [delegate retain];
    [delegate release];
}

RestoreImagesViewModel::~RestoreImagesViewModel() {
    [_queue cancelAllOperations];
    [_dataSource release];
    [_fetchedResultsController release];
    [_queue release];
    [_delegate release];
}

void RestoreImagesViewModel::initialize(NSCollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> *dataSource, std::function<void (NSError * _Nullable)> completionHandler) {
    [_queue addOperationWithBlock:^{
        if (_isInitialized) {
            completionHandler([NSError errorWithDomain:SiliconErrorDomain code:SiliconAlreadyInitializedError userInfo:nullptr]);
            return;
        }
        
        [_dataSource release];
        _dataSource = [dataSource retain];
        
        _delegate.controllerDidChangeContentWithSnapshot = [dataSource = this->_dataSource, queue = this->_queue](auto controller, auto snapshot) {
            [queue addBarrierBlock:^{
                [dataSource applySnapshot:snapshot animatingDifferences:YES];
            }];
        };
        
        NSFetchRequest<RestoreImageModel *> *fetchRequest = [NSFetchRequest<RestoreImageModel *> fetchRequestWithEntityName:@"RestoreImageModel"];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"versions.buildVersion" ascending:YES];
        fetchRequest.sortDescriptors = @[sortDescriptor];
        [sortDescriptor release];
        fetchRequest.returnsObjectsAsFaults = YES;
        
        NSFetchedResultsController<RestoreImageModel *> *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                                        managedObjectContext:this->_dataManager.context()
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
    PersistentDataManager &dataManager = _dataManager;
    
    [localURLs enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [VZMacOSRestoreImage loadFileURL:obj completionHandler:^(VZMacOSRestoreImage * _Nullable restoreImage, NSError * _Nullable error) {
            if (error) {
                completionHandler(error);
                return;
            }
            
            [dataManager.context() performBlock:^{
                RestoreImageModel *restoreImageModel = [[RestoreImageModel alloc] initWithContext:dataManager.context()];
                restoreImageModel.versions = @{
                    _RestoreImageModel::versionKeys::buildVersionKey: restoreImage.buildVersion,
                    _RestoreImageModel::versionKeys::majorVersionKey: @(restoreImage.operatingSystemVersion.majorVersion),
                    _RestoreImageModel::versionKeys::minorVersionKey: @(restoreImage.operatingSystemVersion.minorVersion),
                    _RestoreImageModel::versionKeys::patchVersionKey: @(restoreImage.operatingSystemVersion.patchVersion),
                };
                restoreImageModel.URL = restoreImage.URL;
                [restoreImageModel release];
                
                NSError * _Nullable error = nullptr;
                [dataManager.context() save:&error];
                completionHandler(error);
            }];
        }];
    }];
}

std::shared_ptr<Cancellable> RestoreImagesViewModel::addFromRemote(std::function<void (NSProgress *)> progressHandler, std::function<void (NSError * _Nullable)> completionHandler) {
    __block NSURLSessionDownloadTask * _Nullable _downloadTask = nullptr;
    
    std::shared_ptr<Cancellable> cancellable = std::make_shared<Cancellable>(^{
        [_downloadTask cancel];
    });
    
    PersistentDataManager &dataManager = _dataManager;
    
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
            _downloadTask = nullptr;
            
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
            
            [dataManager.context() performBlock:^{
                RestoreImageModel *restoreImageModel = [[RestoreImageModel alloc] initWithContext:dataManager.context()];
                restoreImageModel.versions = @{
                    _RestoreImageModel::versionKeys::buildVersionKey: restoreImage.buildVersion,
                    _RestoreImageModel::versionKeys::majorVersionKey: @(restoreImage.operatingSystemVersion.majorVersion),
                    _RestoreImageModel::versionKeys::minorVersionKey: @(restoreImage.operatingSystemVersion.minorVersion),
                    _RestoreImageModel::versionKeys::patchVersionKey: @(restoreImage.operatingSystemVersion.patchVersion),
                };
                restoreImageModel.URL = URL;
                [restoreImageModel release];
                
                NSError * _Nullable error = nullptr;
                [dataManager.context() save:&error];
                completionHandler(error);
            }];
        }];
        
        _downloadTask = downloadTask;
        progressHandler(downloadTask.progress);
        [downloadTask resume];
        [session finishTasksAndInvalidate];
    }];
    
    return cancellable;
}
