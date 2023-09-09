//
//  EditVMSidebarViewModel.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/5/23.
//

#import "EditVMSidebarViewModel.hpp"

EditVMSidebarViewModel::EditVMSidebarViewModel() {
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.qualityOfService = NSOperationQualityOfServiceUtility;
    queue.maxConcurrentOperationCount = 1;
    [_queue release];
    _queue = [queue retain];
    [queue release];
}

EditVMSidebarViewModel::~EditVMSidebarViewModel() {
    [_queue cancelAllOperations];
    [_dataSource release];
    [_queue release];
}

void EditVMSidebarViewModel::load(DataSource *dataSource, std::function<void ()> completionHandler) {
    [_queue addOperationWithBlock:^{
        [_dataSource release];
        _dataSource = [dataSource retain];
        
        Snapshot *snapshot = [Snapshot new];
        
        EditVMSidebarSectionModel *sectionModel = [[EditVMSidebarSectionModel alloc] initWithSectionType:EditVMSidebarSectionModelTypeDemo];
        [snapshot appendSectionsWithIdentifiers:@[sectionModel]];
        
        NSArray<EditVMSidebarItemModel *> *itemModels = @[
            [[[EditVMSidebarItemModel alloc] initWithItemType:EditVMSidebarItemModelTypeAudio] autorelease],
            [[[EditVMSidebarItemModel alloc] initWithItemType:EditVMSidebarItemModelTypeGraphics] autorelease],
            [[[EditVMSidebarItemModel alloc] initWithItemType:EditVMSidebarItemModelTypeKeyboards] autorelease],
            [[[EditVMSidebarItemModel alloc] initWithItemType:EditVMSidebarItemModelTypePointingDevices] autorelease],
            [[[EditVMSidebarItemModel alloc] initWithItemType:EditVMSidebarItemModelTypeMemory] autorelease],
            [[[EditVMSidebarItemModel alloc] initWithItemType:EditVMSidebarItemModelTypeNetwork] autorelease],
            [[[EditVMSidebarItemModel alloc] initWithItemType:EditVMSidebarItemModelTypeSharedDirectory] autorelease],
            [[[EditVMSidebarItemModel alloc] initWithItemType:EditVMSidebarItemModelTypeStorage] autorelease],
            [[[EditVMSidebarItemModel alloc] initWithItemType:EditVMSidebarItemModelTypeConsoles] autorelease],
            [[[EditVMSidebarItemModel alloc] initWithItemType:EditVMSidebarItemModelTypeClipboard] autorelease],
        ];
        
        [snapshot appendItemsWithIdentifiers:itemModels intoSectionWithIdentifier:sectionModel];
        [sectionModel release];
        
        [dataSource applySnapshot:snapshot animatingDifferences:YES];
        [snapshot release];
    }];
}

void EditVMSidebarViewModel::itemModel(NSIndexPath * _Nonnull indexPath, std::function<void (EditVMSidebarItemModel * _Nullable)> completionHandler) {
    DataSource *dataSource = _dataSource;
    
    [_queue addOperationWithBlock:^{
        completionHandler([dataSource itemIdentifierForIndexPath:indexPath]);
    }];
}
