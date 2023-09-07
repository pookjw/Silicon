//
//  RestoreImagesViewModel.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 8/29/23.
//

#import <Cocoa/Cocoa.h>
#import <functional>
#import <memory>
#import "RestoreImagesViewModelDelegate.hpp"
#import "RestoreImageModel.hpp"
#import "Cancellable.hpp"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

class RestoreImagesViewModel {
public:
    typedef NSCollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> DataSource;
    
    RestoreImagesViewModel();
    ~RestoreImagesViewModel();
    
    void initialize(DataSource *dataSource, std::function<void (NSError * _Nullable error)> completionHandler);
    
    RestoreImageModel * _Nullable restoreImageModel(NSIndexPath *indexPath);
    void restoreImageModel(NSIndexPath *indexPath, std::function<void (RestoreImageModel * _Nullable)> completionHandler);
    
    void addFromLocalIPSWURLs(NSArray<NSURL *> *localURLs, std::function<void (NSError * _Nullable)> completionHandler);
    std::shared_ptr<Cancellable> addFromRemote(std::function<void (NSProgress *)> progressHandler, std::function<void (NSError * _Nullable)> completionHandler);
    
    RestoreImagesViewModel(const RestoreImagesViewModel&) = delete;
    RestoreImagesViewModel& operator=(const RestoreImagesViewModel&) = delete;
private:
    typedef NSDiffableDataSourceSnapshot<NSString *, NSManagedObjectID *> Snapshot;
    
    DataSource *_dataSource;
    NSFetchedResultsController<RestoreImageModel *> *_fetchedResultsController;
    NSOperationQueue *_queue;
    RestoreImagesViewModelDelegate *_delegate;
    bool _isInitialized = false;
};

NS_HEADER_AUDIT_END(nullability, sendability)
