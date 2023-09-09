//
//  EditVMSidebarViewModel.hpp
//  Silicon
//
//  Created by Jinwoo Kim on 9/5/23.
//

#import <Cocoa/Cocoa.h>
#import <functional>
#import "EditVMSidebarSectionModel.hpp"
#import "EditVMSidebarItemModel.hpp"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

class EditVMSidebarViewModel {
public:
    typedef NSCollectionViewDiffableDataSource<EditVMSidebarSectionModel *, EditVMSidebarItemModel *> DataSource;
    
    EditVMSidebarViewModel();
    ~EditVMSidebarViewModel();
    
    void load(DataSource *dataSource, std::function<void ()> completionHandler);
    void itemModel(NSIndexPath *indexPath, std::function<void (EditVMSidebarItemModel * _Nullable)> completionHandler);
    
    EditVMSidebarViewModel(const EditVMSidebarViewModel&) = delete;
    EditVMSidebarViewModel& operator=(const EditVMSidebarViewModel&) = delete;
private:
    typedef NSDiffableDataSourceSnapshot<EditVMSidebarSectionModel *, EditVMSidebarItemModel *> Snapshot;
    
    NSOperationQueue *_queue;
    DataSource *_dataSource;
};

NS_HEADER_AUDIT_END(nullability, sendability)
