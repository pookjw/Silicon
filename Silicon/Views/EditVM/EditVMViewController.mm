//
//  EditVMViewController.mm
//  Silicon
//
//  Created by Jinwoo Kim on 9/5/23.
//

#import "EditVMViewController.hpp"
#import "EditVMSidebarViewController.hpp"
#import "EditVMMemoryViewController.hpp"
#import "EditVMStorageViewController.hpp"

@interface EditVMViewController () <EditVMSidebarViewControllerDelegate>
@property (retain) NSSplitViewController *splitViewController;
@property (retain) NSSplitViewItem *sidebarItem;
@property (retain) EditVMSidebarViewController *sidebarViewController;
@property (retain) VirtualMachineMacModel *model;
@end

@implementation EditVMViewController

- (instancetype)initWithVirtualMachineMacModel:(VirtualMachineMacModel *)virtualMachineMacModel {
    if (self = [super initWithNibName:nullptr bundle:nullptr]) {
        self.model = virtualMachineMacModel;
    }
    
    return self;
}

- (void)dealloc {
    [_splitViewController release];
    [_sidebarItem release];
    [_sidebarViewController release];
    [_model release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSplitViewController];
    [self setupSidebarViewController];
}

- (void)setupSplitViewController {
    NSSplitViewController *splitViewController = [NSSplitViewController new];
    splitViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:splitViewController.view];
    [NSLayoutConstraint activateConstraints:@[
        [splitViewController.view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [splitViewController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [splitViewController.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [splitViewController.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    [self addChildViewController:splitViewController];
    
    self.splitViewController = splitViewController;
    [splitViewController release];
}

- (void)setupSidebarViewController {
    EditVMSidebarViewController *sidebarViewController = [EditVMSidebarViewController new];
    sidebarViewController.delegate = self;
    
    NSSplitViewItem *sidebarItem = [NSSplitViewItem sidebarWithViewController:sidebarViewController];

    [self.splitViewController addSplitViewItem:sidebarItem];    
    self.sidebarItem = sidebarItem;
    self.sidebarViewController = sidebarViewController;
    [sidebarViewController release];
}

- (void)presentMemoryViewController {
    EditVMMemoryViewController *memoryViewController = [[EditVMMemoryViewController alloc] initWithVirtualMachineMacModel:self.model];
    NSSplitViewItem *contentListItem = [NSSplitViewItem contentListWithViewController:memoryViewController];
    [memoryViewController release];
    [self.splitViewController addSplitViewItem:contentListItem];
}

- (void)presentStorageViewController {
    EditVMStorageViewController *memoryViewController = [[EditVMStorageViewController alloc] initWithVirtualMachineMacModel:self.model];
    NSSplitViewItem *contentListItem = [NSSplitViewItem contentListWithViewController:memoryViewController];
    [memoryViewController release];
    [self.splitViewController addSplitViewItem:contentListItem];
}

#pragma mark - EditVMSidebarViewControllerDelegate

- (void)editVMSidebarViewController:(EditVMSidebarViewController *)viewController didSelectItemModel:(EditVMSidebarItemModel * _Nullable)itemModel {
    switch (itemModel.itemType) {
        case EditVMSidebarItemModelTypeMemory:
            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                [self presentMemoryViewController];
            }];
            break;
        case EditVMSidebarItemModelTypeStorage:
            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                [self presentStorageViewController];
            }];
        default:
            [NSOperationQueue.mainQueue addOperationWithBlock:^{
                __block NSSplitViewItem * _Nullable contentListItem = nullptr;
                [self.splitViewController.splitViewItems enumerateObjectsUsingBlock:^(__kindof NSSplitViewItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.behavior == NSSplitViewItemBehaviorContentList) {
                        contentListItem = obj;
                        *stop = YES;
                    }
                }];
                
                if (contentListItem) {
                    [self.splitViewController removeSplitViewItem:contentListItem];
                }
            }];
            break;
    }
}

@end
