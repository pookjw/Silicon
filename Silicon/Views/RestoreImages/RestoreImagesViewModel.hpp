//
//  RestoreImagesViewModel.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 8/29/23.
//

#import <Cocoa/Cocoa.h>
#import <functional>
#import "RestoreImagesViewModelDelegate.hpp"
#import "PersistentDataManager.hpp"
#import "RestoreImageModel.hpp"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

class RestoreImagesViewModel {
public:
    RestoreImagesViewModel();
    ~RestoreImagesViewModel();
    
    void initialize(NSCollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> *dataSource, std::function<void (NSError * _Nullable error)> completionHandler);
    RestoreImageModel * _Nullable restoreImageModel(NSIndexPath *indexPath);
    void addFromLocalURLs(NSArray<NSURL *> *localURLs, std::function<void (NSError * _Nullable)> completionHandler);
    
    RestoreImagesViewModel(const RestoreImagesViewModel&) = delete;
    RestoreImagesViewModel& operator=(const RestoreImagesViewModel&) = delete;
private:
    NSCollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> *_dataSource;
    NSFetchedResultsController<RestoreImageModel *> *_fetchedResultsController;
    NSOperationQueue *_queue;
    RestoreImagesViewModelDelegate *_delegate;
    bool _isInitialized = false;
    PersistentDataManager &_dataManager;
};

NS_HEADER_AUDIT_END(nullability, sendability)
