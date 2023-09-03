//
//  VirtualMachinesViewModel.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 9/3/23.
//

#import <Cocoa/Cocoa.h>
#import <functional>
#import "VirtualMachineMacModel.hpp"
#import "VirtualMachinesViewModelDelegate.hpp"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

class VirtualMachinesViewModel {
public:
    VirtualMachinesViewModel();
    ~VirtualMachinesViewModel();
    
    void initialize(NSCollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> *dataSource, std::function<void (NSError * _Nullable error)> completionHandler);
    
    VirtualMachineMacModel * _Nullable virtualMachineMacModel(NSIndexPath *indexPath);
    
    VirtualMachinesViewModel(const VirtualMachinesViewModel&) = delete;
    VirtualMachinesViewModel& operator=(const VirtualMachinesViewModel&) = delete;
private:
    NSCollectionViewDiffableDataSource<NSString *, NSManagedObjectID *> *_dataSource;
    NSFetchedResultsController<VirtualMachineMacModel *> *_fetchedResultsController;
    NSOperationQueue *_queue;
    VirtualMachinesViewModelDelegate *_delegate;
    bool _isInitialized = false;
};

NS_HEADER_AUDIT_END(nullability, sendability)
