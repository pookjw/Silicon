//
//  VMsViewModel.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 9/3/23.
//

#import <Cocoa/Cocoa.h>
#import <functional>
#import "VirtualMachineMacModel.hpp"
#import "VMsViewModelDelegate.hpp"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

class VMsViewModel {
public:
    VMsViewModel();
    ~VMsViewModel();
    
    void initialize(NSCollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> *dataSource, std::function<void (NSError * _Nullable error)> completionHandler);
    
    VirtualMachineMacModel * _Nullable virtualMachineMacModel(NSIndexPath *indexPath);
    void virtualMachineMacModel(NSIndexPath *indexPath, std::function<void (VirtualMachineMacModel * _Nullable)> handler);
    
    VMsViewModel(const VMsViewModel&) = delete;
    VMsViewModel& operator=(const VMsViewModel&) = delete;
private:
    NSCollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> *_dataSource;
    NSFetchedResultsController<VirtualMachineMacModel *> *_fetchedResultsController;
    NSOperationQueue *_queue;
    VMsViewModelDelegate *_delegate;
    bool _isInitialized = false;
};

NS_HEADER_AUDIT_END(nullability, sendability)
